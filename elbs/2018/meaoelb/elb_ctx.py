import boto3
from kubernetes import client, config
import sys

REDIRECTOR_SERVICE_NAME = 'redirector'
REDIRECTOR_SERVICE_NAMESPACE = 'redirector'
ELB_ACCESS_SECURITY_GROUP = 'elb_access'


class ELBContext:
    """
    The ELBContext holds on to the AWS clients and K8s clients,
    specific to an AWS region and a K8s cluster.
    """

    def __init__(self, aws_region, dry_run_mode=True):
        config.load_kube_config()
        self.dry_run_mode = dry_run_mode
        self.confirmed_apply = False
        self.v1 = client.CoreV1Api()
        self.ec2_client = boto3.client('ec2', region_name=aws_region)
        self.elb_client = boto3.client('elb', region_name=aws_region)
        self.asg_client = boto3.client('autoscaling', region_name=aws_region)

    def get_cluster_name(self):
        # TODO: clean this up!
        return config.list_kube_config_contexts()[0][0]['name']

    def get_service_nodeport(self, service_namespace, service_name):
        """
        Get the nodeport for a defined service in a namespace
        """
        response = self.v1.read_namespaced_service(
            service_name, service_namespace)
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
        print("\t➤ Creating {} ELB...".format(elb_config.name), end='', flush=True)
        response = self.elb_client.create_load_balancer(
            LoadBalancerName=elb_config.name,
            Listeners=list(map(lambda l: l.to_aws(), elb_config.listeners)),
            SecurityGroups=elb_config.security_groups,
            Subnets=elb_config.subnets,
            Tags=elb_config.tags)
        print("Done")

    def _modify_elb_atts(self, service_config):
        elb_config = service_config.elb_config
        if elb_config.elb_atts:
            print("\t➤ Updating ELB attributes...", end='', flush=True)
            response = self.elb_client.modify_load_balancer_attributes(
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
        response = self.elb_client.configure_health_check(
            LoadBalancerName=elb_config.name,
            HealthCheck={
                'Target': hc_target,
                'Interval': hc.interval,
                'Timeout': hc.timeout,
                'UnhealthyThreshold': hc.unhealthy_threshold,
                'HealthyThreshold': hc.healthy_threshold
            })
        print("Done")

    def prompt_for_apply(self):
        if not self.confirmed_apply:
            result = input("Enter 'make it so' to continue: ")
            if result != 'make it so':
                raise Exception("User cancelled operation")
            else:
                self.confirmed_apply = True

    def create_elb(self, service_config):
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
            return

        if self.dry_run_mode:
            print(
                "\t➤ ELB {} would have been created".format(
                    service_config.elb_config.name))
            return

        self._create_elb(service_config)
        self._modify_elb_atts(service_config)
        self._configure_elb_health_checks(service_config)

    def attach_elbs_to_asg(self, asg_name, elb_names):
        """
        Attach a list of elb names to an ASG
        """
        if self.dry_run_mode:
            print(
                "➤ The following ELBs would have been attached to the {} ASG:".format(asg_name))
            print(elb_names)
            return
        response = self.asg_client.attach_load_balancers(
            AutoScalingGroupName=asg_name,
            LoadBalancerNames=elb_names)

    def attach_all_elbs(self, asg, services):
        """
        Using a list of ServiceConfig objects, extract just the ELB names
        and pass to attach_elbs_to_asg.
        """
        self.attach_elbs_to_asg(
            asg, list(map(lambda e: e.elb_config.name, services)))
