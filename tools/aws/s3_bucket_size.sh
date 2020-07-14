#!/usr/bin/env bash
#
# Queries Cloud Watch to get the size of each S3 bucket in the account.
#
set -euo pipefail

if [ $(uname -s) == "Darwin" ]
then
    YESTERDAY=$(date -v -1d '+%Y-%m-%d')
else
    YESTERDAY=$(date +%Y-%m-%d --date=yesterday)
fi

REGIONS=$(aws ec2 describe-regions --region us-west-2 | jq -r .Regions[].RegionName)


for region in ${REGIONS};
do
    BUCKETS=$(aws cloudwatch list-metrics --namespace "AWS/S3" --region ${region} \
        |  jq -r '.Metrics[].Dimensions[] | select(.Name=="BucketName") | .Value' \
        | sort | uniq)

    for bucket in ${BUCKETS};
    do
        size=$(aws cloudwatch get-metric-statistics --namespace AWS/S3 \
            --start-time ${YESTERDAY}T00:00:00 --end-time ${YESTERDAY}T23:59:59 \
            --period 86400 --statistics Average \
            --region ${region} --metric-name BucketSizeBytes \
            --dimensions Name=BucketName,Value=${bucket}\
            Name=StorageType,Value=StandardStorage \
            | jq -r .Datapoints[].Average)
        echo "${bucket} ${size}"
    done
done
