#!/bin/bash

source ../bin/common.sh
check_meao_env

kubectl create ns surveillance-prod
kubectl run surveillance-prod --image=quay.io/mozmar/surveillance:03ab7a0 -n surveillance-prod
kubectl -n surveillance-prod apply -f ./k8s/surveillance-prod-nodeport.yaml
