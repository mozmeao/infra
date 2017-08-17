#!/bin/bash

#WEB_SERVICE_NAME=web
#K8S_NAMESPACE=mdn-dev

# wait for the ELB that was just created
check_elb() {
    echo "Waiting for ${WEB_SERVICE_NAME} in the namespace ${K8S_NAMESPACE}"
    kubectl -n ${K8S_NAMESPACE} get service ${WEB_SERVICE_NAME} -o json \
            | jq -e -r .status.loadBalancer.ingress[0].hostname
    #> /dev/null 2>&1
}

echo "Waiting for ELB"
until check_elb
do
  sleep 1
done
echo "Found"

# K8s doesn't just store the name of the ELB, it stores the entire hostname
ELB_FULL_NAME=$(kubectl -n ${K8S_NAMESPACE} get service ${WEB_SERVICE_NAME} -o json \
            | jq -r .status.loadBalancer.ingress[0].hostname)

# get the first segment of the hostname, it's the ELB identifier
ELB_NAME=$(echo ${ELB_FULL_NAME} | cut -d. -f1 | cut -d- -f1)
echo "Creating redirector listener on ELB: $ELB_NAME"

# create the ELB
aws elb create-load-balancer-listeners \
        --load-balancer-name ${ELB_NAME} \
        --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=${REDIRECTOR_PORT}" \
        --region ${AWS_REGION}
