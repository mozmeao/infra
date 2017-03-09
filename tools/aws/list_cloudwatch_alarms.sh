#!/bin/bash

# this script dumps all MozMEAO Cloudwatch alarms as JSON via the vli

# describe-regions requires a region, so just pass us-east-1 even though we're
# going to get all regions.
REGIONS=$(aws ec2 describe-regions --region us-east-1 | jq -r '.Regions[].RegionName')
for region in $REGIONS
do
   echo "Checking $region"
   aws cloudwatch describe-alarms --region $region
done
