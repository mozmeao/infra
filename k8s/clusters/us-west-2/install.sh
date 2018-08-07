#!/bin/bash

set -e

source ./config.sh

if [ -z "${AWS_ACCESS_KEY_ID}" ] && [  -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "[Error]: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY is not set"
fi

usage(){
	echo -en "\nUsage: $0 [options] [commands]\n\n"
	echo -en "Options:\n"
	echo -en "  --help              Print this help message\n"
	echo -en "  --debug             Print some debug information\n"
    echo -en "Commands:\n"
	echo -en "  init                Create state buckets\n"
	echo -en "  create-cluster      Create kubernetes cluster\n"
	echo -en "  destroy-cluster     Destroys kubernetes cluster\n"
    echo -en "  roll-cluster        Rolling update cluster\n"
	exit 0
}

init(){
    if aws s3 ls s3://${KOPS_STATE_BUCKET} --region ${KOPS_REGION} 2>&1 | grep -q 'NoSuchBucket'; then
        echo "Creating kops state bucket"
        aws s3 mb s3://${KOPS_STATE_BUCKET} --region ${KOPS_REGION}
        aws s3api put-bucket-versioning --bucket "${KOPS_STATE_BUCKET}" --versioning-configuration Status=Enabled --region ${KOPS_REGION}
    fi
}

create-cluster() {
    echo "Creating kubernetes cluster ${KOPS_CLUSTER}"
    kops create cluster ${KOPS_CLUSTER} \
        --authorization RBAC \
        --cloud aws \
        --kubernetes-version=${KUBERNETES_VERSION} \
        --master-count=${KOPS_MASTER_COUNT} \
        --master-zones=${KOP_MASTER_ZONE} \
        --master-size=${KOPS_MASTER_SIZE} \
        --master-volume-size=${KOPS_MASTER_VOLUME_SIZE_GB} \
        --master-zones=${KOPS_MASTER_ZONES} \
        --networking=${KOPS_NETWORKING} \
        --node-count=${KOPS_NODE_COUNT} \
        --node-size=${KOPS_NODE_SIZE} \
        --node-volume-size=${KOPS_NODE_VOLUME_SIZE_GB} \
        --zones=${KOPS_ZONE} \
        --target=terraform
}

update-cluster() {
    echo "Updating kubernetes cluster ${KOPS_CLUSTER}"
    kops update cluster ${KOPS_CLUSTER} \
        --state=s3://${KOPS_STATE_BUCKET} \
        --target=terraform
}

roll-cluster() {
    echo "Rolling kubernetes cluster ${KOPS_CLUSTER}"
    kops rolling-update cluster ${KOPS_CLUSTER} \
        --state=s3://${KOPS_STATE_BUCKET} \
        --master-interval=8m \
        --node-interval=8m \
        --yes
}

validate-cluster(){
    echo "Validating kubernetes cluster ${KOPS_CLUSTER}"
    kops validate cluster ${KOPS_CLUSTER}
}

# TODO: Make sure there is confirmation
destroy-cluster(){
    echo "Destroying kubernetes cluster ${KOPS_CLUSTER}"
    kops delete cluster ${KOPS_CLUSTER} \
        --yes
}

while [ "$1" != "" ]; do
	case $1 in
		-x | --debug )
			set -x
			export TF_LOG='DEBUG'
			;;
		-h | --help | help )
			usage
			;;
		init )
			shift
			init
			GOT_COMMAND=1
			;;
		create-cluster )
			shift
			create-cluster
			GOT_COMMAND=1
			;;
		update-cluster )
			shift
			update-cluster
			GOT_COMMAND=1
			;;
        roll-cluster )
            shift
            roll-cluster
            GOT_COMMAND=1
            ;;
		destroy-cluster )
			shift
			destroy-cluster
			GOT_COMMAND=1
			;;
		*)
			usage
			;;
	esac
	shift
done

# If we did not get a valid command print the help message
if [ "${GOT_COMMAND:-0}" == 0 ]; then
	usage
	exit 1
fi
