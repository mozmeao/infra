#!/bin/bash -e

export TERRAFORM_ENV="tokyo"
export ELB_PROVISIONING_REGION="ap-northeast-1"
export TF_VAR_region="ap-northeast-1"
export TF_VAR_vpc_id="vpc-cd1f99a9"
export KOPS_NAME="tokyo.moz.works"

# source this file to generate a snippets tfvars file via gen_tf_elb_cfg
. ../tf/elb_utils.sh

SNIPPETS_VARFILE=$(pwd)/snippets-tokyo.tfvars
SNIPPETS_STATS_VARFILE=$(pwd)/snippets-stats-tokyo.tfvars
CAREERS_VARFILE=$(pwd)/careers-tokyo.tfvars

TOKYO_SUBNETS="subnet-ed79369b"
# param order: elb name, namespace, nodeport service name, subnets
gen_tf_elb_cfg "snippets" \
               "snippets-prod" \
               "snippets-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/snippets.mozilla.com" > $SNIPPETS_VARFILE

gen_tf_elb_cfg "snippets-stats" \
               "snippets-stats" \
               "snippets-stats-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:acm:ap-northeast-1:236517346949:certificate/3fd8337d-9476-46a9-acda-47abc3b95472" > $SNIPPETS_STATS_VARFILE

gen_tf_elb_cfg "careers" \
               "careers-prod" \
               "careers-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/careers-mozilla-org" > $CAREERS_VARFILE

# gen configs from other load balancers here

# Apply Terraform
cd ../tf && ./common.sh \
    -var-file $SNIPPETS_VARFILE \
    -var-file $SNIPPETS_STATS_VARFILE \
    -var-file $CAREERS_VARFILE

# attach each ELB to the k8s nodes ASG
ASG_NAME="nodes.${KOPS_NAME}"

# Run these if reattaching ELBs to ASG
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.tokyo.moz.works \
#        --load-balancer-name careers \
#        --region us-east-1
#
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.tokyo.moz.works \
#        --load-balancer-name snippets \
#        --region us-east-1

echo "Assigning ELB careers instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names careers \
    --region "${TF_VAR_region}"

echo "Assigning ELB snippets instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names snippets \
    --region "${TF_VAR_region}"

echo "Assigning ELB snippets-stats instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names snippets-stats \
    --region "${TF_VAR_region}"

attach_nodeport_sg_to_nodes_sg

