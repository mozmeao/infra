#!/bin/bash -e
HELM_VERSION=v2.1.3
if [ -z "${KOPS_INSTALLER}" ]; then
    echo "KOPS_INSTALLER must be set to the infra/k8s/install directory"
    exit -1
fi

if [ -z "${STAGE2_ETC_PATH}" ]; then
	echo "STAGE2_ETC_PATH must be set"
	exit -1
fi

# let's make sure we are in the right directory
terraform output region > /dev/null 2>&1
if [ $? -ne 0 ]
then
	echo "Please run from <mycluster>/out/terraform directory"
	exit 1
fi

install_y2j() {
	which y2j > /dev/null
	if [ $? -ne 0 ]; then
		echo "Installing y2j"
		sudo docker run --rm wildducktheories/y2j y2j.sh installer /usr/local/bin | sudo bash
	else
		echo "y2j already installed"
	fi
}

install_kubectl() {
	which kubectl > /dev/null
	if [ $? -ne 0 ]; then
		echo "Installing kubectl"
		curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
		chmod +x ./kubectl
		sudo mv ./kubectl /usr/local/bin/kubectl
	else
		echo "kubectl already installed"
	fi
}

install_helm() {
	echo "Downloading helm"
	which helm > /dev/null
	if [ $? -ne 0 ]; then
		echo "Installing helm client"
		(cd /tmp && \
			wget https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
			tar xzf /tmp/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
			sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm)
		  echo "Done installing helm client"
	fi
}

install_deis_client() {
	which deis > /dev/null
	if [ $? -ne 0 ]; then
		echo "Installing deis cli"
		curl -o deis https://storage.googleapis.com/workflow-cli-master/deis-latest-linux-amd64
		chmod +x deis
		sudo mv ./deis /usr/local/bin/deis
	else
		echo "Deis cli already installed"
	fi
}

install_deps() {
	install_y2j
	install_kubectl
	install_helm
	install_deis_client
}

install_mig() {
	echo "Installing mig"
	kubectl create namespace mig | true
	kubectl -n mig create secret generic mig-agent-secrets \
		--from-file=${STAGE2_ETC_PATH}/agent.key \
		--from-file=${STAGE2_ETC_PATH}/agent.crt \
		--from-file=${STAGE2_ETC_PATH}/ca.crt \
		--from-file=${STAGE2_ETC_PATH}/mqpassword \
		--from-file=${STAGE2_ETC_PATH}/mig-agent.cfg
	kubectl -n mig create -f ${STAGE2_ETC_PATH}/migdaemonset.yaml
}

install_dd() {
	echo "Installing Datadog"
	kubectl create namespace datadog | true
	kubectl create -f ${STAGE2_ETC_PATH}/dd-agent.yaml
}

install_newrelic() {
	echo "Installing New Relic"
	kubectl create namespace newrelic | true

	kubectl create -f ${STAGE2_ETC_PATH}/newrelic-config.yaml
	# replace "mycluster" with the SHORT_NAME specified in stage1.sh
	cat ${STAGE2_ETC_PATH}/newrelic-daemonset.yaml.template | sed "s/mycluster/${KOPS_SHORT_NAME}/" | kubectl create -f -
}

install_k8s_dashboard() {
	echo "Installing k8s dashboard"
	kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
}

install_heapster() {
	echo "Installing heapster"
	kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.2.0.yaml
}

install_fluentd() {
	echo "Installing fluentd"

    cat ${STAGE2_ETC_PATH}/fluentd.yaml | \
        sed "s/TEMPL_SYSLOG_HOST/${SYSLOG_HOST}/" | \
        sed "s/TEMPL_SYSLOG_PORT/${SYSLOG_PORT}/" | \
    	kubectl create -f -
}


install_tiller() {
	echo "Installing tiller"
	helm init
	echo "Waiting for tiller to start"
	# TODO: hackey version of waiting for a pod to start, REPLACE THIS
	until kubectl -n kube-system get pods | grep tiller | grep Running | grep "1/1"
	do
		sleep 1
	done
	echo "Tiller installed!"
}



install_workflow() {
	echo "Installing Deis Workflow"
	helm repo add deis https://charts.deis.com/workflow
	helm inspect values deis/workflow | sed -n '1!p' > workflow_config.yaml

	# s3 settings
	region=$(terraform output -json | jq -r .region.value)
	registry_bucket=$(terraform output -json | jq -r '."registry-bucket"'.value)
	builder_bucket=$(terraform output -json | jq -r '."builder-bucket"'.value)
	s3_accesskey=$(terraform output -json | jq -r '."deis_s3_accesskey"'.value)
	s3_secretkey=$(terraform output -json | jq -r '."deis_s3_secretkey"'.value)

	# rds settings
	if [ -z "${KOPS_EXISTING_RDS}" ]
	then
		echo "Using new RDS instance"
		pgsql_address=$(terraform output -json | jq -r '."pgsql_address"'.value)
		pgsql_db_name=$(terraform output -json | jq -r '."pgsql_db_name"'.value)
		pgsql_password=$(terraform output -json | jq -r '."pgsql_password"'.value)
		pgsql_port=$(terraform output -json | jq -r '."pgsql_port"'.value)
		pgsql_username=$(terraform output -json | jq -r '."pgsql_username"'.value)
	else
		echo "Using existing RDS settings"
		pgsql_address=${KOPS_PGSQL_ADDRESS}
		pgsql_db_name=${KOPS_PGSQL_DB_NAME}
		pgsql_password=${KOPS_PGSQL_PASSWORD}
		pgsql_port=${KOPS_PGSQL_PORT}
		pgsql_username=${KOPS_PGSQL_USERNAME}
	fi

    # this block of code sets up:
    # - global s3 storage + aws creds
    # - RDS postgres host/port/username/password
    # - Deis registration disabled
	y2j < workflow_config.yaml \
		| jq ".global.storage = \"s3\"" \
		| jq ".s3.region = \"${region}\"" \
		| jq ".s3.registry_bucket = \"${registry_bucket}\"" \
		| jq ".s3.builder_bucket = \"${builder_bucket}\"" \
		| jq ".s3.database_bucket = \"\"" \
		| jq ".s3.accesskey = \"${s3_accesskey}\"" \
		| jq ".s3.secretkey = \"${s3_secretkey}\"" \
		| jq ".global.database_location = \"off-cluster\"" \
		| jq ".database.password = \"${pgsql_password}\"" \
		| jq ".database.postgres.host = \"${pgsql_address}\"" \
		| jq ".database.postgres.name = \"${pgsql_db_name}\"" \
		| jq ".database.postgres.password = \"${pgsql_password}\"" \
		| jq ".database.postgres.port = \"${pgsql_port}\"" \
		| jq ".database.postgres.username = \"${pgsql_username}\"" \
		| jq ".controller.registration_mode = \"disabled\"" \
		| j2y > workflow_config_moz.yaml

    # if you are reinstalling Deis after a `helm delete ...`, you'll need to delete
    # the secrets as well:
    #  kubectl -n deis get secrets | tail -n +2 | awk '{ print $1 }' | xargs kubectl -n deis delete secret

    rm -rf ./workflow
    # fetch the deis/workflow charts and write them to ./workflow
    helm fetch deis/workflow --untar

    # remove components we aren't using
    comps_to_remove=( monitor logger fluentd redis nsqd )
    for comp in "${comps_to_remove[@]}"
    do
        echo "Removing ${comp}"
        rm -rf ./workflow/charts/${comp}
    done

    # if installing an unmodified deis/workflow:
	# helm install deis/workflow --namespace deis -f workflow_config_moz.yaml
    # otherwise, we're using our tweaked version on the local filesystem:
    helm install ./workflow --namespace deis -f workflow_config_moz.yaml
}

config_deis_elb() {
    echo "Waiting for Deis router LB"
    # the -e flag to jq will cause it to return a 1 if the path isn't found in the json
    until kubectl --namespace=deis get svc deis-router -o json | jq -e -r .status.loadBalancer.ingress[0].hostname
    do
      sleep 1
    done
    echo "Deis router LB available"

    ELB=$(kubectl --namespace=deis get svc deis-router -o json | jq -r .status.loadBalancer.ingress[0].hostname)
    echo "ELB = ${ELB}"
    BASE_ELB_NAME=$(echo $ELB | tr "-" " " | awk '{ print $1 }')
    echo "BASE ELB = ${BASE_ELB_NAME}"

    echo "Setting ELB IdleTimeout to 1200 seconds"
    aws elb modify-load-balancer-attributes \
            --load-balancer-name ${BASE_ELB_NAME} \
            --load-balancer-attributes "{\"ConnectionSettings\":{\"IdleTimeout\":1200}}" \
            --region ${KOPS_REGION}

    echo "Done"
}

config_deis_dns() {
    echo "Waiting for Deis router LB"
    # the -e flag to jq will cause it to return a 1 if the path isn't found in the json
    until kubectl --namespace=deis get svc deis-router -o json | jq -e -r .status.loadBalancer.ingress[0].hostname
    do
        sleep 1
    done
    echo "Deis router LB available"

    NEW_VALUE="*.${KOPS_SHORT_NAME}.${KOPS_DOMAIN}"
    echo "Configuring Deis DNS for *.${KOPS_SHORT_NAME}.${KOPS_DOMAIN}"

    LONG_ZONE_ID=$(aws route53 list-hosted-zones | jq -r ".HostedZones[]  | select(.Name == \"${KOPS_DOMAIN}.\") | .Id")
    HOSTED_ZONE_ID=$(echo "${LONG_ZONE_ID}" | tr '/' ' ' | awk '{ print $2 }')
    INPUT_JSON=$(cat ${KOPS_INSTALLER}/etc/deis_router_dns.yaml | \
        sed "s/DNS_NAME/${NEW_VALUE}/" | \
        sed "s/DNS_VALUE/${ELB}/" | \
        sed "s/HOSTED_ZONE_ID/${HOSTED_ZONE_ID}/" | y2j)

    aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --cli-input-json "${INPUT_JSON}"
    echo "Done"
}


install_deps
install_tiller

# k8s specific
if [ "${INSTALL_DASHBOARD}" -eq 1 ]; then install_k8s_dashboard; fi
if [ "${INSTALL_HEAPSTER}" -eq 1 ]; then install_heapster; fi

# MozMEAO monitoring
if [ "${INSTALL_MIG}" -eq 1 ]; then install_mig; fi
if [ "${INSTALL_DATADOG}" -eq 1 ]; then install_dd; fi
if [ "${INSTALL_NEWRELIC}" -eq 1 ]; then install_newrelic; fi
if [ "${INSTALL_FLUENTD}" -eq 1 ]; then install_fluentd; fi

if [ "${INSTALL_WORKFLOW}" -eq 1 ]; then
    install_workflow
    config_deis_elb
    config_deis_dns
fi


