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
BEDROCK_STAGE_VARFILE=$(pwd)/bedrock-stage-tokyo.tfvars
BEDROCK_PROD_VARFILE=$(pwd)/bedrock-prod-tokyo.tfvars
WILCARD_ALLIZOM_VARFILE=$(pwd)/wildcard-allizom-tokyo.tfvars
NUCLEUS_PROD_VARFILE=$(pwd)/nucleus-prod-tokyo.tfvars
SURVEILLANCE_PROD_VARFILE=$(pwd)/surveillance-prod-tokyo.tfvars
BASKET_STAGE_VARFILE=$(pwd)/basket-stage-tokyo.tfvars
BASKET_PROD_VARFILE=$(pwd)/basket-prod-tokyo.tfvars

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

gen_tf_elb_cfg "bedrock-stage" \
               "bedrock-stage" \
               "bedrock-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/wildcard.allizom.org_20180103" > $BEDROCK_STAGE_VARFILE

gen_tf_elb_cfg "bedrock-prod" \
               "bedrock-prod" \
               "bedrock-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:acm:ap-northeast-1:236517346949:certificate/099d5838-a413-478a-abc1-afb67c4017f1" > $BEDROCK_PROD_VARFILE

gen_tf_elb_cfg "wildcard-allizom" \
               "deis" \
               "deis-router" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:iam::236517346949:server-certificate/wildcard.allizom.org_20180103" > $WILCARD_ALLIZOM_VARFILE

gen_tf_elb_cfg "basket-stage" \
               "basket-stage" \
               "basket-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:acm:ap-northeast-1:236517346949:certificate/f2f3eb0a-c9c9-4404-b89d-16d3e47b8bcc" > $BASKET_STAGE_VARFILE \
               "http"

gen_tf_elb_cfg "basket-prod" \
               "basket-prod" \
               "basket-nodeport" \
               "${TOKYO_SUBNETS}" \
               "arn:aws:acm:ap-northeast-1:236517346949:certificate/9c13521f-c93e-42f0-b969-b11fd571ff91" > $BASKET_PROD_VARFILE \
               "http"

gen_dummy_elb_cfg "nucleus-prod" > $NUCLEUS_PROD_VARFILE
gen_dummy_elb_cfg "surveillance-prod" > $SURVEILLANCE_PROD_VARFILE

# gen configs from other load balancers here

# Apply Terraform
# NOTE: we're passing in dummy values for nucleus prod as Terraform needs 
#       them set, even though we're not creating a nucleus prod elb in Tokyo
cd ../tf && ./common.sh \
    -var-file $BASKET_PROD_VARFILE \
    -var-file $BASKET_STAGE_VARFILE \
    -var-file $BEDROCK_PROD_VARFILE \
    -var-file $BEDROCK_STAGE_VARFILE \
    -var-file $CAREERS_VARFILE \
    -var-file $NUCLEUS_PROD_VARFILE \
    -var-file $SNIPPETS_STATS_VARFILE \
    -var-file $SNIPPETS_VARFILE \
    -var-file $SURVEILLANCE_PROD_VARFILE \
    -var-file $WILCARD_ALLIZOM_VARFILE

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
#
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.tokyo.moz.works \
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

echo "Assigning ELB basket-stage instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names basket-stage \
    --region "${TF_VAR_region}"

echo "Assigning ELB basket-prod instances from ASG ${ASG_NAME}"
aws autoscaling attach-load-balancers \
    --auto-scaling-group-name "${ASG_NAME}" \
    --load-balancer-names basket-prod \
    --region "${TF_VAR_region}"

attach_nodeport_sg_to_nodes_sg

