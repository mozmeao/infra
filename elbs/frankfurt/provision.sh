#!/bin/bash -e

export TERRAFORM_ENV="frankfurt"
export ELB_PROVISIONING_REGION="eu-central-1"
export TF_VAR_region="eu-central-1"
export TF_VAR_vpc_id="vpc-4d036a25"
export KOPS_NAME="frankfurt.moz.works"

# source this file to generate a snippets tfvars file via gen_tf_elb_cfg
. ../tf/elb_utils.sh

SNIPPETS_VARFILE=$(pwd)/snippets-frankfurt.tfvars
SNIPPETS_STATS_VARFILE=$(pwd)/snippets-stats-frankfurt.tfvars
CAREERS_VARFILE=$(pwd)/careers-frankfurt.tfvars
BEDROCK_STAGE_VARFILE=$(pwd)/bedrock-stage-frankfurt.tfvars
BEDROCK_PROD_VARFILE=$(pwd)/bedrock-prod-frankfurt.tfvars
WILCARD_ALLIZOM_VARFILE=$(pwd)/wildcard-allizom-frankfurt.tfvars
NUCLEUS_PROD_VARFILE=$(pwd)/nucleus-prod-frankfurt.tfvars
SURVEILLANCE_PROD_VARFILE=$(pwd)/surveillance-prod-frankfurt.tfvars
BASKET_STAGE_VARFILE=$(pwd)/basket-stage-frankfurt.tfvars
BASKET_PROD_VARFILE=$(pwd)/basket-prod-frankfurt.tfvars

FRANKFURT_SUBNETS="subnet-10685f78"

# param order: elb name, namespace, nodeport service name, subnets, cert arn, nodeport proto (defaults to https)
gen_tf_elb_cfg "snippets" \
               "snippets-prod" \
               "snippets-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               $(get_iam_cert_arn "snippets.mozilla.com") > $SNIPPETS_VARFILE

gen_tf_elb_cfg "snippets-stats" \
               "snippets-stats" \
               "snippets-stats-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               $(get_acm_cert_arn ${ELB_PROVISIONING_REGION} "snippets-stats.moz.works") > $SNIPPETS_STATS_VARFILE

gen_tf_elb_cfg "careers" \
               "careers-prod" \
               "careers-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               $(get_iam_cert_arn "careers-mozilla-org") > $CAREERS_VARFILE

# www.allizom.org has multiple validate certs, so we hardcode the desired value
gen_tf_elb_cfg "bedrock-stage" \
               "bedrock-stage" \
               "bedrock-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               "arn:aws:acm:eu-central-1:236517346949:certificate/bd00d1ef-57a9-4e65-8bff-7db5c95d477d" \
                   > $BEDROCK_STAGE_VARFILE

gen_tf_elb_cfg "bedrock-prod" \
               "bedrock-prod" \
               "bedrock-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               $(get_acm_cert_arn ${ELB_PROVISIONING_REGION} "www.mozilla.org") > $BEDROCK_PROD_VARFILE

# wildcard uses an iam cert
gen_tf_elb_cfg "wildcard-allizom" \
               "deis" \
               "deis-router" \
               "${FRANKFURT_SUBNETS}" \
               $(get_iam_cert_arn "wildcard.allizom.org_20180103") > $WILCARD_ALLIZOM_VARFILE


gen_dummy_elb_cfg "nucleus-prod" > $NUCLEUS_PROD_VARFILE
gen_dummy_elb_cfg "surveillance-prod" > $SURVEILLANCE_PROD_VARFILE


#gen_tf_elb_cfg "nucleus-prod" \
#               "nucleus-prod" \
#               "nucleus-nodeport" \
#               "${FRANKFURT_SUBNETS}" \
#               $(get_acm_cert_arn ${ELB_PROVISIONING_REGION} "nucleus.mozilla.org") \
#               "http" > $NUCLEUS_PROD_VARFILE
#
#gen_tf_elb_cfg "surveillance-prod" \
#               "surveillance-prod" \
#               "surveillance-nodeport" \
#               "${FRANKFURT_SUBNETS}" \
#               $(get_acm_cert_arn ${ELB_PROVISIONING_REGION} "surveillance.mozilla.org") \
#               "http" > $SURVEILLANCE_PROD_VARFILE

gen_tf_elb_cfg "basket-stage" \
               "basket-stage" \
               "basket-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               $(get_acm_cert_arn ${ELB_PROVISIONING_REGION} "basket.allizom.org") \
               "http" > $BASKET_STAGE_VARFILE

gen_tf_elb_cfg "basket-prod" \
               "basket-prod" \
               "basket-nodeport" \
               "${FRANKFURT_SUBNETS}" \
               $(get_acm_cert_arn ${ELB_PROVISIONING_REGION} "basket.mozilla.org") \
               "http" > $BASKET_PROD_VARFILE

# gen configs from other load balancers here

# Apply Terraform
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
#        --auto-scaling-group-name nodes.frankfurt.moz.works \
#        --load-balancer-name careers \
#        --region us-east-1
#
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.frankfurt.moz.works \
#        --load-balancer-name snippets \
#        --region us-east-1
#
#aws autoscaling detach-load-balancers \
#        --auto-scaling-group-name nodes.frankfurt.moz.works \
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

#echo "Assigning ELB nucleus-prod instances from ASG ${ASG_NAME}"
#aws autoscaling attach-load-balancers \
#    --auto-scaling-group-name "${ASG_NAME}" \
#    --load-balancer-names nucleus-prod \
#    --region "${TF_VAR_region}"


#echo "Assigning ELB surveillance-prod instances from ASG ${ASG_NAME}"
#aws autoscaling attach-load-balancers \
#    --auto-scaling-group-name "${ASG_NAME}" \
#    --load-balancer-names surveillance-prod \
#    --region "${TF_VAR_region}"

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

