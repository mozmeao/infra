#!/usr/bin/env python3
import boto3
import fire


def elbs_for_instance_id(instance_id, region=None):
    # AWS_DEFAULT_REGION env var also works
    elb_client = boto3.client('elb', region_name=region)
    elbs = [elb['LoadBalancerName'] for elb in
            elb_client.describe_load_balancers()['LoadBalancerDescriptions']
            if instance_id in (i['InstanceId'] for i in elb['Instances'])]
    elbs.sort()
    return elbs


def main(instance_id, region=None):
    print(' '.join(elbs_for_instance_id(instance_id, region=region)))


if __name__ == '__main__':
    fire.Fire(main)
