#!/bin/bash -x

# wait for the ELB that was just created
check_elb() {
    echo "Waiting for ${WEB_SERVICE_NAME} in the namespace ${K8S_NAMESPACE}"
    kubectl -n ${K8S_NAMESPACE} get service ${WEB_SERVICE_NAME} -o json \
            | jq -e -r .status.loadBalancer.ingress[0].hostname
    #> /dev/null 2>&1
}

# wait until the ELB check doesn't return an error
wait_for_elb() {
    echo "Waiting for ELB"
    until check_elb
    do
      sleep 1
    done
    echo "Found"
}

get_elb_name() {
    # K8s doesn't just store the name of the ELB, it stores the entire hostname
    ELB_FULL_NAME=$(kubectl -n ${K8S_NAMESPACE} get service ${WEB_SERVICE_NAME} -o json \
                | jq -r .status.loadBalancer.ingress[0].hostname)
    # get the first segment of the hostname, it's the ELB identifier
    echo ${ELB_FULL_NAME} | cut -d. -f1 | cut -d- -f1
}

create_redirector_listener() {
    echo "Creating redirector listener on ELB: $ELB_NAME"
    # create the ELB
    aws elb create-load-balancer-listeners \
            --load-balancer-name ${ELB_NAME} \
            --listeners "Protocol=TCP,LoadBalancerPort=80,InstanceProtocol=TCP,InstancePort=${REDIRECTOR_PORT}" \
            --region ${AWS_REGION}
}

add_elb_access_security_group() {
    ELB_ACCESS_GROUP_ID=$(aws ec2 describe-security-groups  \
                            --filters "Name=group-name,Values=elb_access" \
                            --region ${AWS_REGION} \
                            | jq -e -r .SecurityGroups[0].GroupId)

    aws elb apply-security-groups-to-load-balancer \
        --load-balancer-name ${ELB_NAME} \
        --security-groups ${ELB_ACCESS_GROUP_ID} \
        --region ${AWS_REGION}
}


ELB_S3_LOGGING_PREFIX=${ELB_S3_LOGGING_PREFIX} \

add_logging() {
    echo "Adding S3 logging on ELB: $ELB_NAME"
    aws elb modify-load-balancer-attributes \
        --load-balancer-name ${ELB_NAME} \
        --load-balancer-attributes "{\"AccessLog\": {\"Enabled\": ${ELB_S3_LOGGING_ENABLED}, \"S3BucketName\": \"${ELB_S3_LOGGING_BUCKET}\", \"EmitInterval\": ${ELB_S3_LOGGING_INTERVAL}, \"S3BucketPrefix\": \"${ELB_S3_LOGGING_PREFIX}\"}}" \
        --region ${AWS_REGION}
}

configure_elb_timeout() {
    echo "Setting ELB idle timeout"
    aws elb modify-load-balancer-attributes \
        --load-balancer-name ${ELB_NAME} \
        --load-balancer-attributes "{\"ConnectionSettings\":{\"IdleTimeout\":${WEB_GUNICORN_TIMEOUT}}}" \
        --region ${AWS_REGION}
}

# wait until the ELB is ready to be configured
wait_for_elb
export ELB_NAME=$(get_elb_name)
# add an http port that will redirect to https via the redirector service
create_redirector_listener
# allow ELB port 80 to connect to a NodePort
add_elb_access_security_group
# add S3 bucket logging
add_logging
# set a longer ELB idle timeout
configure_elb_timeout
