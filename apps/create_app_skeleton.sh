#!/bin/bash

if [ -z "${1}" ]; then
  echo "Please specify an application mame"
  exit 1
fi

clusters=(frankfurt tokyo virginia)

APPNAME=$1
mkdir -p $APPNAME
mkdir -p $APPNAME/docs
echo "# ${APPNAME} support documentation" > $APPNAME/docs/support.md
mkdir -p $APPNAME/k8s
mkdir -p $APPNAME/infra/multi_region
mkdir -p $APPNAME/infra/multi_region/tf

for cluster in "${clusters[@]}"; do
    mkdir -p $APPNAME/infra/multi_region/${cluster}
    touch $APPNAME/infra/multi_region/${cluster}/provision.sh
done
touch $APPNAME/infra/multi_region/tf/common.sh
touch $APPNAME/infra/multi_region/tf/main.tf
touch $APPNAME/infra/multi_region/tf/variables.tf
touch $APPNAME/infra/multi_region/tf/outputs.tf

mkdir -p $APPNAME/infra/shared
touch $APPNAME/infra/shared/provision.sh
touch $APPNAME/infra/shared/main.tf
cp ./etc/script_template.sh $APPNAME/scale.sh
cp ./etc/script_template.sh $APPNAME/setup.sh
cp ./etc/script_template.sh $APPNAME/teardown.sh
echo "# ${APPNAME} provisioning\n" > $APPNAME/README.md

find . -name "*.sh" -exec chmod +x {} \;

tree ./$APPNAME
