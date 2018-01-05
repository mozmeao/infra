import boto3
import click
import os
from slacker import Slacker
from meaocron.jobs.slack import SlackClient

"""
Ensure that all ELB's bound to an ASG exist
"""

class ASGCheck:
    def __init__(self, region, slack):
        self.region = region
        self.asgclient = boto3.client('autoscaling', region_name=region)
        self.elbclient = boto3.client('elb', region_name=region)
        self.slack = slack

    def get_asg_bound_elbs(self):
        unique_elbs = set()
        asg_response = self.asgclient.describe_auto_scaling_groups()
        for asg in asg_response[u'AutoScalingGroups']:
            asgname = asg[u'AutoScalingGroupName']
            print("ASG:{}".format(asgname))
            #print(asg['LoadBalancerNames'])
            print("  Bound ELBs:")
            for elb in asg[u'LoadBalancerNames']:
                print("    ", elb)
                unique_elbs.add(elb)
            print("")
        return unique_elbs

    def check_existing_elbs(self, asg_elbs):
        elb_response = self.elbclient.describe_load_balancers()
        elbs = elb_response[u'LoadBalancerDescriptions']
        elb_names = set(map(lambda e: e[u'LoadBalancerName'], elbs))
        #print(elb_names)
        if asg_elbs <= elb_names:
            msg = "ALL bound ELBs exist in {}".format(self.region)
            print(msg)
            self.slack_info(msg)
        else:
            elbdiff = asg_elbs - elb_names
            msg = "Not all bound ELBs exist: {}".format(elbdiff)
            self.slack_error(msg)

    def slack_info(self, msg):
        if self.slack:
            self.slack.info(msg)

    def slack_error(self, msg):
        if self.slack:
            self.slack.error(msg)

    def run(self):
        print("-" * 50)
        print("Checking ASGs in", self.region)
        self.check_existing_elbs(self.get_asg_bound_elbs())

@click.command()
@click.option('--region', '-r', multiple=True)
@click.option('--slackchannel', '-s')
@click.option('-e', default=False, is_flag=True, help="Only show errors")
def asgcheck(region, slackchannel, e):
    if 'ASGCHECK_SLACK_TOKEN' in os.environ:
        apitoken = os.environ['ASGCHECK_SLACK_TOKEN']
    else:
        apitoken = None
    if apitoken and slackchannel:
        slack = SlackClient(apitoken, slackchannel, e)
    else:
        slack = None

    for r in region:
        ASGCheck(r, slack).run()

if __name__ == '__main__':
    asgcheck()