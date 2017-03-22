# are we running from a directory with config.sh?
check_cwd() {
    if [ ! -f config.sh ]; then
        echo "Can't find config.sh in cwd"
        exit 1
    fi
}

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
    kubectl create -f etc/datadog_statsd_svc.yaml
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
    helm install ${KOPS_INSTALLER}/charts/mozmeao --set fluentd.syslog_host=${SYSLOG_HOST},fluentd.syslog_port=${SYSLOG_PORT}
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

# use this if you need to reinstall Deis and secrets already exist
delete_deis_secrets() {
    kubectl -n deis get secrets | tail -n +2 | awk '{ print $1 }' | xargs kubectl -n deis delete secret
}

install_workflow_chart() {
    # make sure we're running from a directory with config.sh
    check_cwd
    echo "Installing Deis Workflow"
    helm repo add deis https://charts.deis.com/workflow
    helm inspect values deis/workflow | sed -n '1!p' > workflow_config.yaml
    TF_OUTPUT_CMD="terraform output --state ./out/terraform/.terraform/terraform.tfstate"

    # s3 settings
    region=$(${TF_OUTPUT_CMD} region)
    registry_bucket=$(${TF_OUTPUT_CMD} registry-bucket)
    builder_bucket=$(${TF_OUTPUT_CMD} builder-bucket)
    s3_accesskey=$(${TF_OUTPUT_CMD} deis_s3_accesskey)
    s3_secretkey=$(${TF_OUTPUT_CMD} deis_s3_secretkey)

    # rds settings
    if [ -z "${KOPS_EXISTING_RDS}" ]
    then
        echo "Using new RDS instance"
        pgsql_address=$(${TF_OUTPUT_CMD} pgsql_address)
        pgsql_db_name=$(${TF_OUTPUT_CMD} pgsql_db_name)
        pgsql_password=$(${TF_OUTPUT_CMD} pgsql_password)
        pgsql_port=$(${TF_OUTPUT_CMD} pgsql_port)
        pgsql_username=$(${TF_OUTPUT_CMD} pgsql_username)
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
        | jq ".registry_location = \"off-cluster\"" \
        | jq ".\"registry-token-refresher\".off_cluster_registry.hostname = \"${REGISTRY_HOSTNAME}\"" \
        | jq ".\"registry-token-refresher\".off_cluster_registry.organization = \"${REGISTRY_ORG}\"" \
        | jq ".\"registry-token-refresher\".off_cluster_registry.username = \"${REGISTRY_USERNAME}\"" \
        | jq ".\"registry-token-refresher\".off_cluster_registry.password = \"${REGISTRY_PASSWORD}\"" \
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

    # SSL is handled at the ELB, but the ELB still wants to point to the Deis router SSL
    # port internally. We change the ssl port to be unencrypted (http) internally.
    # TODO: use a template with condition and submit upstream
    sed -i "s/6443/8080/" workflow/charts/router/templates/router-service.yaml

    # if installing an unmodified deis/workflow:
    # helm install deis/workflow --namespace deis -f workflow_config_moz.yaml
    # otherwise, we're using our tweaked version on the local filesystem:
    helm install ./workflow --namespace deis -f workflow_config_moz.yaml
}

# configure Deis Workflow annotations for ELB timeout, DNS, proxy protocol,
# and SSL certs
config_annotations() {
    # https://deis.com/docs/workflow/managing-workflow/configuring-load-balancers/
    # Configure proxy protocol
    kubectl --namespace=deis annotate service/deis-router \
        service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout=1200

    kubectl --namespace=deis annotate deployment/deis-router \
        router.deis.io/nginx.useProxyProtocol=true

    kubectl --namespace=deis annotate service/deis-router \
        service.beta.kubernetes.io/aws-load-balancer-proxy-protocol='*'

    # this creates a DNS entry for *.foo.moz.works and points it at the ELB for us
    # NOTE: if the *.foo.moz.works record already exists, changes will not be applied.
    # Watch the logs for changes via:
    # kubectl -n kube-system logs dns-controller-foo -f
    kubectl --namespace=deis annotate service/deis-router \
        dns.alpha.kubernetes.io/external="*.${KOPS_NAME}"

    AWS_ACCOUNT_ID=$(aws ec2 describe-security-groups --group-names 'Default' --region ${KOPS_REGION} | jq -r .SecurityGroups[0].OwnerId)

    # https config for k8s
    # https://github.com/kubernetes/kubernetes/issues/24978
    CERT_ARN=$(aws acm list-certificates --region ${KOPS_REGION} | jq -r ".CertificateSummaryList[] | select(.DomainName == \"${KOPS_NAME}\") | .CertificateArn")
    CERT_ID=$(echo $CERT_ARN | tr '/' ' ' | awk '{ print $2 }')
    ANNOTATION1="service.beta.kubernetes.io/aws-load-balancer-ssl-cert=${CERT_ARN}"
    kubectl --namespace=deis annotate service/deis-router ${ANNOTATION1}

    ANNOTATION2="service.beta.kubernetes.io/aws-load-balancer-ssl-ports=https"
    kubectl --namespace=deis annotate service/deis-router ${ANNOTATION2}
}

config_deis_router_hpa() {
    # export the current Deis router config and add resource requests to it
    # so the HPA can calculate "CURRENT". Reimport it via kubectl apply, then
    #create the HPA
    TARGET_CPU=70
    LIMITS_CPU=1
    LIMITS_MEMORY="2048Mi"
    REQUESTS_CPU=1
    REQUESTS_MEMORY="1024Mi"

    REQUESTS_PATH=".spec.template.spec.containers[0].resources.requests"
    LIMITS_PATH=".spec.template.spec.containers[0].resources.limits"
    kubectl -n deis get --export deployment deis-router -o json | \
         jq "${LIMITS_PATH}.cpu = \"${LIMITS_CPU}\"" | \
         jq "${LIMITS_PATH}.memory = \"${LIMITS_MEMORY}\"" | \
         jq "${REQUESTS_PATH}.cpu = \"${REQUESTS_CPU}\"" | \
         jq "${REQUESTS_PATH}.memory = \"${REQUESTS_MEMORY}\"" | \
         kubectl -n deis apply -f -

    kubectl -n deis autoscale deployment deis-router \
        --min=1 --max=${KOPS_NODE_COUNT} --cpu-percent=${TARGET_CPU}
}

# install Deis Workflow components and perform post-intall configuration
install_deis() {
    check_cwd
    install_workflow_chart
    config_annotations
    config_deis_router_hpa
}
