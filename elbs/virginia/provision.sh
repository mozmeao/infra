#!/bin/bash -e

export TERRAFORM_ENV="virginia"
export ELB_PROVISIONING_REGION="us-east-1"
export TF_VAR_region="us-east-1"
export TF_VAR_vpc_id="vpc-1b35a07d"
export KOPS_NAME="virginia.moz.works"

# source this file to generate a snippets tfvars file via gen_tf_elb_cfg
. ../tf/elb_utils.sh

SNIPPETS_VARFILE=$(pwd)/snippets-virginia.tfvars
SNIPPETS_STATS_VARFILE=$(pwd)/snippets-stats-virginia.tfvars
CAREERS_VARFILE=$(pwd)/careers-virginia.tfvars

BEDROCK_STAGE_VARFILE=$(pwd)/bedrock-stage-virginia.tfvars
BEDROCK_PROD_VARFILE=$(pwd)/bedrock-prod-virginia.tfvars
WILCARD_ALLIZOM_VARFILE=$(pwd)/wildcard-allizom-virginia.tfvars

NUCLEUS_PROD_VARFILE=$(pwd)/nucleus-prod-virginia.tfvars

SURVEILLANCE_PROD_VARFILE=$(pwd)/surveillance-prod-virginia.tfvars

VIRGINIA_SUBNETS="subnet-43125f6e,subnet-a699aaef,subnet-b6ceb6ed"

# param order: elb name, namespace, nodeport service name, subnets, cert arn, nodeport proto (defaults to https)
gen_tf_elb_cfg "snippets" \
               "snippets-prod" \
               "snippets-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/snippets.mozilla.com" > $SNIPPETS_VARFILE

gen_tf_elb_cfg "snippets-stats" \
               "snippets-stats" \
               "snippets-stats-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:acm:us-east-1:236517346949:certificate/caf5907d-9804-4a16-9f3f-29193fb25565" > $SNIPPETS_STATS_VARFILE

gen_tf_elb_cfg "careers" \
               "careers-prod" \
               "careers-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/careers-mozilla-org" > $CAREERS_VARFILE

gen_tf_elb_cfg "bedrock-stage" \
               "bedrock-stage" \
               "bedrock-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:acm:us-east-1:236517346949:certificate/ecb993c5-e2e5-4864-9509-855aaafec0c9" > $BEDROCK_STAGE_VARFILE

gen_tf_elb_cfg "bedrock-prod" \
               "bedrock-prod" \
               "bedrock-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:acm:us-east-1:236517346949:certificate/2c9700af-4cf3-415f-9554-00d40c972fcd" > $BEDROCK_PROD_VARFILE

gen_tf_elb_cfg "wildcard-allizom" \
               "deis" \
               "deis-router" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/wildcard.allizom.org_20180103" > $WILCARD_ALLIZOM_VARFILE

gen_tf_elb_cfg "nucleus-prod" \
               "nucleus-prod" \
               "nucleus-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:acm:us-east-1:236517346949:certificate/fa2f75df-e710-4e2a-b210-2647c4179dac" > $NUCLEUS_PROD_VARFILE \
               "http"

gen_tf_elb_cfg "surveillance-prod" \
               "surveillance-prod" \
               "surveillance-nodeport" \
               "${VIRGINIA_SUBNETS}" \
               "arn:aws:acm:us-east-1:236517346949:certificate/2eb042da-5a62-4430-bc6e-1623ebad2030" > $SURVEILLANCE_PROD_VARFILE \
               "http"

# gen configs from other load balancers here

# Apply Terraform
cd ../tf && ./common.sh \
    -var-file $SNIPPETS_VARFILE \
    -var-file $SNIPPETS_STATS_VARFILE \
    -var-file $CAREERS_VARFILE \
    -var-file $BEDROCK_PROD_VARFILE \
    -var-file $BEDROCK_STAGE_VARFILE \
    -var-file $WILCARD_ALLIZOM_VARFILE \
    -var-file $NUCLEUS_PROD_VARFILE \
    -var-file $SURVEILLANCE_PROD_VARFILE

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
#
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.virginia.moz.works \
#        --load-balancer-name snippets-stats \
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

echo "Assigning ELB bedrock-stage instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names bedrock-stage \
    --region "${TF_VAR_region}"

echo "Assigning ELB bedrock-prod instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names bedrock-prod \
    --region "${TF_VAR_region}"

echo "Assigning ELB wilcard-allizom instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names wildcard-allizom \
    --region "${TF_VAR_region}"

echo "Assigning ELB nucleus-prod instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names nucleus-prod \
    --region "${TF_VAR_region}"


echo "Assigning ELB surveillance-prod instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names surveillance-prod \
    --region "${TF_VAR_region}"

attach_nodeport_sg_to_nodes_sg

