import boto3
from kubernetes import client, config
import sys
from deepdiff import DeepDiff
from pprint import pprint

from meaoelb.config import ELBConfig
from meaoelb.templates import *

REDIRECTOR_SERVICE_NAME = 'redirector'
REDIRECTOR_SERVICE_NAMESPACE = 'redirector'
ELB_ACCESS_SECURITY_GROUP = 'elb_access'


class ELBContext:
    """
    The ELBContext holds on to the AWS clients and K8s clients,
    specific to an AWS region and a K8s cluster.
    """

    def __init__(self, aws_region, dry_run_mode=True, connect_to_k8s=True):
        if connect_to_k8s:
            config.load_kube_config()
            self.v1 = client.CoreV1Api()
        else:
            self.v1 = None

        self.dry_run_mode = dry_run_mode
        self.confirmed_apply = False
        self.ec2_client = boto3.client('ec2', region_name=aws_region)
        self.elb_client = boto3.client('elb', region_name=aws_region)
        self.asg_client = boto3.client('autoscaling', region_name=aws_region)

    def get_cluster_name(self):
        # TODO: clean this up!
        return config.list_kube_config_contexts()[0][0]['name']

    def get_service_nodeport(
            self,
            service_namespace,
            service_name,
            nodeport_name_filter=None):
        """
        Get the nodeport for a defined service in a namespace
        """
        response = self.v1.read_namespaced_service(
            service_name, service_namespace)
        if nodeport_name_filter:
            port_matches = [
                portdef.node_port for portdef in response.spec.ports if portdef.name == nodeport_name_filter]
            if len(port_matches) != 1:
                raise Exception(
                    "Can't find nodeport {} for service {} in namespace {}".format(
                        nodeport_name_filter, service_name, service_namespace))
            else:
                return port_matches[0]
        else:
            if len(response.spec.ports) > 1:
                # pass in a nodeport_name_filter!
                raise Exception(
                    "More than 1 nodeport available for service {} in namespace {}".format(
                        service_name, service_namespace))
            return response.spec.ports[0].node_port

    def get_redirector_service_nodeport(self):
        """
        Get the nodeport for the redirector service
        """
        return self.get_service_nodeport(
            REDIRECTOR_SERVICE_NAME,
            REDIRECTOR_SERVICE_NAMESPACE)

    def elb_exists(self, elb_name):
        """
        Check to see if an ELB already exists
        """
        try:
            response = self.elb_client.describe_load_balancers(
                LoadBalancerNames=[elb_name])
            if len(response['LoadBalancerDescriptions']) == 1:
                return True
            else:
                return False
        except BaseException:
            return False

    def get_elb_access_security_group(self, vpc_id):
        """
        Get the security group ID of the our elb_access group.
        Most AWS functions require security group ID instead of security group name.
        """

        response = self.ec2_client.describe_security_groups(
            Filters=[{'Name': 'group-name', 'Values': [ELB_ACCESS_SECURITY_GROUP]},
                     {'Name': 'vpc-id', 'Values': [vpc_id]}])
        if len(response['SecurityGroups']) != 1:
            raise Exception(
                "elb_access security group missing or duplicates found in vpc ",
                vpc_id)
        return response['SecurityGroups'][0]['GroupId']

    def _create_elb(self, service_config):
        elb_config = service_config.elb_config
        print(
            "\t➤ Creating {} ELB...".format(
                elb_config.name),
            end='',
            flush=True)
        self.elb_client.create_load_balancer(
            LoadBalancerName=elb_config.name,
            Listeners=[l.to_aws() for l in elb_config.listeners.values()],
            SecurityGroups=elb_config.security_groups,
            Subnets=elb_config.subnets,
            Tags=elb_config.tags)
        print("Done")

    def _modify_elb_atts(self, service_config):
        elb_config = service_config.elb_config
        if elb_config.elb_atts:
            print("\t➤ Updating ELB attributes...", end='', flush=True)
            self.elb_client.modify_load_balancer_attributes(
                LoadBalancerName=elb_config.name,
                LoadBalancerAttributes=elb_config.elb_atts.to_aws())
            print("Done")
        else:
            print("➤ No ELB attributes defined")

    def _configure_elb_health_checks(self, service_config):
        elb_config = service_config.elb_config
        print("\t➤ Creating health checks...", end='', flush=True)
        hc = elb_config.health_check
        hc_target = "{}:{}{}".format(
            hc.target_proto,
            hc.target_port,
            hc.target_path)
        self.elb_client.configure_health_check(
            LoadBalancerName=elb_config.name,
            HealthCheck={
                'Target': hc_target,
                'Interval': hc.interval,
                'Timeout': hc.timeout,
                'UnhealthyThreshold': hc.unhealthy_threshold,
                'HealthyThreshold': hc.healthy_threshold
            })
        print("Done")

    def _attach_elb_to_asg(self, service_config, asg_name):
        """
        Attach a single ELB to an ASG
        """
        if self.dry_run_mode:
            print(
                "➤ The {} ELB would have been attached to the {} ASG:".format(
                    service_config.elb_config.name, asg_name))
            return
        print("\t➤ Attaching to ASG...", end='', flush=True)
        self.asg_client.attach_load_balancers(
            AutoScalingGroupName=asg_name,
            LoadBalancerNames=[service_config.elb_config.name])
        print("Done")

    def prompt_for_apply(self):
        if not self.confirmed_apply:
            result = input("Enter 'make it so' to continue: ")
            if result != 'make it so':
                raise Exception("User cancelled operation")
            else:
                self.confirmed_apply = True

    def create_elb(self, service_config, asg_name):
        """
        Create an ELB, modify it's attributes, and create health checks.
        """
        if self.get_cluster_name() != service_config.target_cluster:
            print(
                "➤ Currently connected to {} K8s cluster, which is not the target: {}".format(
                    self.get_cluster_name(),
                    service_config.target_cluster))
            return

        if not self.dry_run_mode and not self.confirmed_apply:
            self.prompt_for_apply()

        print("➤ Processing {}".format(service_config.elb_config.name))
        if self.elb_exists(service_config.elb_config.name):
            print(
                "\t➤ {} has already been provisioned".format(
                    service_config.elb_config.name))
            self.test_elb(service_config.elb_config)
            return

        if self.dry_run_mode:
            print(
                "\t➤ ELB {} would have been created".format(
                    service_config.elb_config.name))
            return

        self._create_elb(service_config)
        self._modify_elb_atts(service_config)
        self._configure_elb_health_checks(service_config)
        self._attach_elb_to_asg(service_config, asg_name)

    def attach_elbs_to_asg(self, asg_name, elb_names):
        """
        Attach a list of elb names to an ASG
        """
        if self.dry_run_mode:
            print(
                "➤ The following ELBs would have been attached to the {} ASG:".format(asg_name))
            print(elb_names)
            return
        self.asg_client.attach_load_balancers(
            AutoScalingGroupName=asg_name,
            LoadBalancerNames=elb_names)

    def attach_all_elbs(self, asg, services):
        """
        Using a list of ServiceConfig objects, extract just the ELB names
        and pass to attach_elbs_to_asg.
        """
        self.attach_elbs_to_asg(
            asg, list(map(lambda e: e.elb_config.name, services)))

    def test_elb(self, elb_config):
        """
        Compare the defined config with whats in AWS. Convert the local config
        to a dict, and use DeepDiff to spot any differences.
        """
        try:
            elb_response = self.elb_client.describe_load_balancers(
                LoadBalancerNames=[elb_config.name])
        except Exception as e:
            s = str(e)
            if "There is no ACTIVE Load Balancer" in s:
                print("\t➤ ELB does not exist: {}".format(elb_config.name))
                return
            else:
                raise e
        atts_response = self.elb_client.describe_load_balancer_attributes(
            LoadBalancerName=elb_config.name)
        tags_response = self.elb_client.describe_tags(
            LoadBalancerNames=[elb_config.name])

        elb_def = elb_response['LoadBalancerDescriptions'][0]
        atts = atts_response['LoadBalancerAttributes']
        tags = tags_response['TagDescriptions'][0]['Tags']
        c = ELBConfig.from_aws(elb_def, atts, tags)
        ddiff = DeepDiff(dict(elb_config), dict(c), ignore_order=True)
        if ddiff != {}:
            print("\t➤ ELB config for {} has diverged:".format(elb_config.name))
            print("!" * 30)
            print('- Values marked "new_value" are from AWS')
            print('- Values marked "old_value" are from local ELB config')

            pprint(ddiff, indent=2)
            print("!" * 30)
        else:
            print("\t➤ ELB config is valid: {}".format(c.name))

    def gen_region(self):
        """
        Generates Python ELB automation code for a given region.
        """
        print(HEADER_TEMPLATE)
        elbs = self.elb_client.describe_load_balancers()
        all_methods = []
        for elb_def in elbs['LoadBalancerDescriptions']:
            elb_name = elb_def['LoadBalancerName']
            elb_response = self.elb_client.describe_load_balancers(
                LoadBalancerNames=[elb_name])
            atts_response = self.elb_client.describe_load_balancer_attributes(
                LoadBalancerName=elb_name)
            tags_response = self.elb_client.describe_tags(
                LoadBalancerNames=[elb_name])
            elb_def = elb_response['LoadBalancerDescriptions'][0]
            atts = atts_response['LoadBalancerAttributes']
            tags = tags_response['TagDescriptions'][0]['Tags']
            c = ELBConfig.from_aws(elb_def, atts, tags)
            (code, method_name) = c.gen_code()
            print(code)
            all_methods.append(method_name)
        for method_name in all_methods:
            print("elb_tool.define_generic_elb({}())".format(method_name))
        print(FOOTER_TEMPLATE)
