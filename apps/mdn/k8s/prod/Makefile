MYSQL_IMAGE ?= quay.io/mozmar/mdn-mysql
MYSQL_IMAGE_TAG ?= latest
MYSQL_PERSISTENCE_SIZE ?= 100Gi
export MYSQL_RELEASE ?= mdn
export K8S_NAMESPACE ?= mdn-prod

k8s-kuma-web:
	j2 kuma.yaml.j2 web.prod.env | kubectl create -n ${K8S_NAMESPACE} -f -

k8s-mysql-install:
	helm install \
	    --name ${MYSQL_RELEASE} \
		--namespace ${K8S_NAMESPACE} \
		--version 0.2.6 \
		stable/mysql \
		--set image=${MYSQL_IMAGE},imageTag=${MYSQL_IMAGE_TAG},persistence.size=${MYSQL_PERSISTENCE_SIZE}

# Those tasks don't have file targets
.PHONY: k8s-kuma-web k8s-mysql-install
