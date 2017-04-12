#!/bin/bash -e

export ELB_PROVISIONING_REGION="us-east-1"
export TF_VAR_region="us-east-1"
export TF_VAR_vpc_id="vpc-1b35a07d"
export KOPS_NAME="virginia.moz.works"

# source this file to generate a snippets tfvars file via gen_tf_elb_cfg
. ../tf/elb_utils.sh

SNIPPETS_VARFILE=$(pwd)/snippets-virginia.tfvars
CAREERS_VARFILE=$(pwd)/careers-virginia.tfvars

VIRGINIA_SUBNETS="subnet-43125f6e,subnet-a699aaef,subnet-b6ceb6ed"
# param order: elb name, namespace, nodeport service name, subnets
gen_tf_elb_cfg "snippets" \
               "snippets-prod" \
               "snippets-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/snippets.mozilla.com" > $SNIPPETS_VARFILE


gen_tf_elb_cfg "careers" \
               "careers-prod" \
               "careers-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/careers-mozilla-org" > $CAREERS_VARFILE

# gen configs from other load balancers here

# Apply Terraform
cd ../tf && ./common.sh \
    -var-file $SNIPPETS_VARFILE \
    -var-file $CAREERS_VARFILE

# attach each ELB to the k8s nodes ASG
ASG_NAME="nodes.${KOPS_NAME}"

# Run these if reattaching ELBs to ASG
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.virginia.moz.works \
#        --load-balancer-name careers \
#        --region us-east-1
#
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.virginia.moz.works \
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

attach_nodeport_sg_to_nodes_sg

