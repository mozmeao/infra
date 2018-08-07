# Creating kubernetes cluster
Kubernetes clusters are configured using kops, each cluster created right now will have 3 masters and 3 nodes in each availability zones

## Requirements
You will need the following tools to get kubernetes installed

- kops
- terraform
- kubectl
- awscli

## Checklist

- choose AWS region + AZ
- choose an external DNS name
    - Create external DNS name
- choose cluster name

