# see if a var is defined
check_var() {
    echo -n "$1 = "
    v=$(eval echo "\$$1")
    if [ -z "$v" ]; then
        echo "NOT DEFINED"
        exit -1
    else
        echo "$v"
    fi
}

set_tf_resource_name() {
    export TF_RESOURCE_NAME=$(echo ${KOPS_NAME} | tr "." "-")
}

verify_env() {
    required_vars=( KOPS_SHORT_NAME KOPS_DOMAIN KOPS_NAME KOPS_REGION TF_STATE_BUCKET
                    KOPS_NODE_COUNT KOPS_NODE_SIZE KOPS_MASTER_SIZE KOPS_PUBLIC_KEY
                    KOPS_ZONES KOPS_MASTER_ZONES KOPS_STATE_BUCKET )
    echo ""
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    echo "Environment"
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    for v in "${required_vars[@]}"
    do
        check_var $v
    done

    set_tf_resource_name
    IFS=',' read -ra AZ_LIST <<< ${KOPS_ZONES}
    ZONE_COUNT="${#AZ_LIST[@]}"

    echo "TF_RESOURCE_NAME=${TF_RESOURCE_NAME}"
    echo "ZONE_COUNT=${ZONE_COUNT}"

    echo "All vars set"
    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    echo ""
}

run_kops() {
    aws s3 mb s3://${KOPS_STATE_BUCKET} --region ${KOPS_REGION} || true
    # for regions with < 3 AZ's, install master in a single region
    if [ $ZONE_COUNT -lt 3 ]; then
        local zones="${AZ_LIST[0]}"
        local master_zones="${AZ_LIST[0]}"
    else
        local zones=$KOPS_ZONES
        local master_zones=$KOPS_ZONES
    fi

    kops create cluster ${KOPS_NAME} \
        --cloud aws \
        --zones=${zones} \
        --master-zones=${master_zones} \
        --target=terraform \
        --node-count=${KOPS_NODE_COUNT} \
        --node-size=${KOPS_NODE_SIZE} \
        --master-size=${KOPS_MASTER_SIZE} \
        --ssh-public-key=${KOPS_PUBLIC_KEY} \
        --kubernetes-version=${KOPS_K8S_VERSION}
}

build_subnet_ids() {
    local count=0
    for az in "${AZ_LIST[@]}"
    do
        az=$(tr -d ' ' <<< "${az}")
        if [ $count -ne 0 ]; then
            echo -n ","
        fi
        echo -n "\"\${aws_subnet.${az}-${TF_RESOURCE_NAME}.id\"}"
        let "count+=1"
    done
}

render_tf_templates() {
    # https://github.com/hashicorp/terraform/issues/4084
    # we use sed here to generate Terraform files from "templates"
    # if we need more than 3 vars, consider a different approach.
    # Generate a terraform file for creating s3 buckets for Deis
    cat ${KOPS_INSTALLER}/etc/deis_s3.tf.template \
        | sed s/KOPS_REGION/${KOPS_REGION}/g \
        | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
        | sed s/KOPS_NAME/${KOPS_NAME}/g \
        > ./out/terraform/deis_s3.tf

    if [ -z "${KOPS_EXISTING_RDS}" ]
    then
        echo "Creating new RDS instance"
        # generate a terraform file to create an RDS instance
        KOPS_AZS=$(build_subnet_ids)

        # DP TODO
        # aws_subnet.KOPS_AZ0-TF_RESOURCE_NAME.id
        cat ${KOPS_INSTALLER}/etc/deis_rds.tf.template \
            | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
            | sed s/KOPS_NAME/${KOPS_NAME}/g \
            | sed s/KOPS_AZS/${KOPS_AZS}/g \
            > ./out/terraform/deis_rds.tf

        # generate a terraform file with RDS instance variables
        cat ${KOPS_INSTALLER}/etc/deis_rds_variables.tf.template \
            | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
            > ./out/terraform/deis_rds_variables.tf
    else
        echo "Using existing RDS instance"
    fi
}

setup_tf_s3_state_store() {
    cd out/terraform
    echo "Creating Terraform state bucket at s3://${TF_STATE_BUCKET} (region ${KOPS_REGION})"
    # The following environment variables are defined in config.sh
    aws s3 mb s3://${TF_STATE_BUCKET} --region ${KOPS_REGION} || true

    echo "Configuring Terraform to use an encrypted remote S3 bucket for state storage"
    # store TF state in S3
    terraform remote config \
        -backend=s3 \
        -backend-config="bucket=${TF_STATE_BUCKET}" \
        -backend-config="key=${KOPS_SHORT_NAME}/terraform.tfstate" \
        -backend-config="encrypt=1" \
        -backend-config="region=${KOPS_REGION}"
    echo "Encryption for TF state:"
    aws s3api head-object --bucket=$TF_STATE_BUCKET --key=${KOPS_SHORT_NAME}/terraform.tfstate | jq -r .ServerSideEncryption
    cd ../../
}

generate_cluster_autoscaler_tf() {
    if [ ! -f config.sh ]; then
        echo "Please change to the directory containing config.sh"
        exit 1
    fi
    set_tf_resource_name
    cat ${KOPS_INSTALLER}/etc/cluster_autoscaler_policy.tf.template \
            | sed s/TF_RESOURCE_NAME/${TF_RESOURCE_NAME}/g \
            | sed s/TF_SHORT_NAME/${KOPS_SHORT_NAME}/g \
            > ./out/terraform/cluster_autoscaler_policy.tf
    # set ASG max size so to allow the cluster autoscaler to scale up
    sed -i "s/max_size = $KOPS_NODE_COUNT/max_size = $DEFAULT_MAX/" ./out/terraform/kubernetes.tf
}
