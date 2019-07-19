#!/bin/bash -e

TF_VERSION=0.11.14

asdf install terraform ${TF_VERSION}
asdf local terraform ${TF_VERSION}

terraform init
PLAN=$(mktemp)
terraform plan --out $PLAN

echo "Please verify plan output above and enter the command"
echo "'make it so' followed by enter to continue."
echo "Otherwise, Ctrl-C to abort"
read

terraform apply $PLAN
