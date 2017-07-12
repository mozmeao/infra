#!/bin/sh

export SNIPPETS_REGION="ap-northeast-1"
export TERRAFORM_ENV="tokyo"
export TF_VAR_region="ap-northeast-1"
export TF_VAR_region_short="tokyo"
export TF_VAR_fqdn_prod="snippets-prod.tokyo.moz.works"
export TF_VAR_fqdn_stage="snippets-stage.tokyo.moz.works"
export TF_VAR_alarm_name_prod="Snippets Prod Tokyo"
export TF_VAR_alarm_name_stage="Snippets Stage Tokyo"
##### Redis config
export TF_VAR_cache_node_size="cache.m4.xlarge"
export TF_VAR_cache_port=6379
export TF_VAR_cache_num_nodes=3
export TF_VAR_cache_engine_version="2.8.24"
export TF_VAR_cache_param_group="default.redis2.8"

cd ../tf && ./common.sh

