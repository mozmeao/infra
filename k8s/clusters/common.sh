#!/bin/bash

export KUBERNETES_VERSION="v1.9.7"

export KOPS_DOMAIN="mdn.mozit.cloud"

export KOPS_MASTER_COUNT=3
export KOPS_MASTER_SIZE=m4.large
export KOPS_MASTER_VOLUME_SIZE_GB=250
export KOPS_NETWORKING=calico
export KOPS_NODE_COUNT=3
export KOPS_NODE_SIZE=m4.xlarge
export KOPS_NODE_VOLUME_SIZE_GB=250

# s3 bucket
# Generate random hash by doing
# date +%s | md5sum | cut -d ' ' -f 1
export KOPS_STATE_BUCKET="kops-state-4e366a3ac64d1b4022c8b5e35efbd288"
export KOPS_STATE_STORE="s3://${KOPS_STATE_BUCKET}"

export STATE_BUCKET="mdn-state-4e366a3ac64d1b4022c8b5e35efbd288"
export STATE_BUCKET_STORE="s3://${STATE_BUCKET}"
