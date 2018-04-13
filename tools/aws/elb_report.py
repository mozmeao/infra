"""Generate a per-region tsv file listing AWS ELBs (ALBs, NLBs NOT included)"""

import boto3
import click


class ELBRegionReport:
    # ordered TSV fields
    FIELDS = [
        'elb_name',
        'dns_name',
        'vpc_id',
        'bound_asgs',
        'security_groups',
        'availability_zones',
        'subnets',
        'hc_target',
        'hc_interval',
        'hc_timeout',
        'hc_unhealthy_threshold',
        'hc_healthy_threshold',
        'atts_cross_zone_load_balancing',
        'atts_access_log',
        'atts_connection_draining',
        'atts_idle_timeout',
        'tags',
        'listener_0',
        'listener_1',
        'listener_2',
        'listener_3',
        'listener_4',
        'listener_5'
    ]
    MAX_LISTENERS = 6

    def __init__(self, region):
        self.elb_client = boto3.client('elb', region_name=region)
        self.asg_client = boto3.client('autoscaling', region_name=region)

    def load_region_asgs(self):
        # load asgs once for all elbs in this region
        region_asgs = self.asg_client.describe_auto_scaling_groups()
        self.region_asgs = region_asgs['AutoScalingGroups']

    def get_bound_asgs(self, elb_name):
        bound_asgs = []

        for asg in self.region_asgs:
            if elb_name in asg['LoadBalancerNames']:
                bound_asgs.append(asg['AutoScalingGroupName'])
        return bound_asgs

    def gen_line(self, elb):
        line = {}

        elb_name = elb['LoadBalancerName']
        line['elb_name'] = elb_name
        line['dns_name'] = elb['DNSName']
        line['vpc_id'] = elb['VPCId']
        bound_asgs = self.get_bound_asgs(elb_name)
        line['bound_asgs'] = ",".join(bound_asgs)

        line['security_groups'] = ",".join(elb['SecurityGroups'])
        line['availability_zones'] = ",".join(elb['AvailabilityZones'])
        line['subnets'] = ",".join(elb['Subnets'])

        # health check
        line['hc_target'] = elb['HealthCheck']['Target']
        line['hc_interval'] = str(elb['HealthCheck']['Interval'])
        line['hc_timeout'] = str(elb['HealthCheck']['Timeout'])
        line['hc_unhealthy_threshold'] = str(
            elb['HealthCheck']['UnhealthyThreshold'])
        line['hc_healthy_threshold'] = str(
            elb['HealthCheck']['HealthyThreshold'])

        # attributes
        atts = self.elb_client.describe_load_balancer_attributes(
            LoadBalancerName=elb_name)
        atts = atts['LoadBalancerAttributes']
        line['atts_cross_zone_load_balancing'] = atts['CrossZoneLoadBalancing']
        line['atts_access_log'] = atts['AccessLog']
        line['atts_connection_draining'] = atts['ConnectionDraining']
        line['atts_idle_timeout'] = atts['ConnectionSettings']['IdleTimeout']

        # make sure we have enough tsv columns to show the max # of listeners
        if len(elb['ListenerDescriptions']) > self.MAX_LISTENERS:
            raise Exception("Please add additional listener_N columns (up to {})".format(
                len(elb['ListenerDescriptions'])))

        # listeners
        for idx, listener in enumerate(elb['ListenerDescriptions']):
            listener = listener['Listener']
            key = "listener_{}".format(idx)
            line[key] = str(listener)

        tags = self.elb_client.describe_tags(LoadBalancerNames=[elb_name])
        line['tags'] = str(tags['TagDescriptions'][0]['Tags'])

        # render a tsv line
        line_txt = "\t".join([str(line.get(field, ''))
                              for field in self.FIELDS])
        print(line_txt)

    def gen_report(self):
        self.load_region_asgs()
        # print tsv header
        print("\t".join(self.FIELDS))
        elb_descriptions = self.elb_client.describe_load_balancers()
        for elb in elb_descriptions['LoadBalancerDescriptions']:
            self.gen_line(elb)


@click.command()
@click.option('--region', prompt='region', help='The AWS region')
def doit(region):
    """Generate a per-region TSV file"""
    ELBRegionReport(region).gen_report()


if __name__ == '__main__':
    doit()
