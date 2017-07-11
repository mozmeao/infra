#!/bin/sh

export SNIPPETS_REGION="eu-central-1"
export TERRAFORM_ENV="frankfurt"

export TF_VAR_region="eu-central-1"
export TF_VAR_region_short="frankfurt"
export TF_VAR_fqdn_prod="snippets-prod.frankfurt.moz.works"
export TF_VAR_fqdn_stage="snippets-stage.frankfurt.moz.works"
export TF_VAR_alarm_name_prod="Snippets Prod Frankfurt"
export TF_VAR_alarm_name_stage="Snippets Stage Frankfurt"
##### Redis config
export TF_VAR_cache_node_size="cache.m4.xlarge"
export TF_VAR_cache_port=6379
export TF_VAR_cache_num_nodes=3
export TF_VAR_cache_engine_version="2.8.24"
export TF_VAR_cache_param_group="default.redis2.8"

cd ../tf && ./common.sh

