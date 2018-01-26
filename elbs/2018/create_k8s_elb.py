import boto3
from kubernetes import client, config
from collections import namedtuple
import pprint

REDIRECTOR_SERVICE_NAME = 'redirector'
REDIRECTOR_SERVICE_NAMESPACE = 'redirector'
ELB_ACCESS_SECURITY_GROUP = 'elb_access'

config.load_kube_config()
v1 = client.CoreV1Api()

# TODO
AWS_REGION = 'us-west-2'
ec2_client = boto3.client('ec2', region_name=AWS_REGION)
elb_client = boto3.client('elb', region_name=AWS_REGION)
asg_client = boto3.client('autoscaling', region_name=AWS_REGION)


def get_cluster_name():
    # TODO
    return config.list_kube_config_contexts()[0][0]['name']


def get_service_nodeport(service_namespace, service_name):
    response = v1.read_namespaced_service(service_name, service_namespace)
    return response.spec.ports[0].node_port


def get_redirector_service_nodeport():
    return get_service_nodeport(
        REDIRECTOR_SERVICE_NAME,
        REDIRECTOR_SERVICE_NAMESPACE)


def elb_exists(elb_name):
    try:
        response = elb_client.describe_load_balancers(
            LoadBalancerNames=[elb_name])
        if len(response['LoadBalancerDescriptions']) == 1:
            return True
        else:
            return False
    except BaseException:
        return False


def get_elb_access_security_group(vpc_id):
    response = ec2_client.describe_security_groups(
        Filters=[{'Name': 'group-name', 'Values': [ELB_ACCESS_SECURITY_GROUP]},
                 {'Name': 'vpc-id', 'Values': [vpc_id]}])
    if len(response['SecurityGroups']) != 1:
        raise Exception(
            "elb_access security group missing or duplicates found in vpc ",
            vpc_id)
    return response['SecurityGroups'][0]['GroupId']


class DictLike(dict):
    def __getattr__(self, key):
        return self[key]

    def __setattr__(self, key, value):
        self[key] = value

# Config classes and defaults


class ServiceConfig(DictLike):
    def __init__(
            self,
            namespace,
            name,
            target_cluster,
            elb_config,
            vpc_id,
            subnet_ids):
        self.namespace = namespace
        self.name = name
        self.target_cluster = target_cluster
        self.elb_config = elb_config
        self.vpc_id = vpc_id
        self.subnet_ids = subnet_ids


class ELBConfig(DictLike):
    def __init__(
            self,
            name,
            listeners,
            security_groups,
            subnets,
            tags,
            health_check,
            elb_atts=None):
        self.name = name
        self.listeners = listeners
        self.security_groups = security_groups
        self.subnets = subnets
        self.tags = tags
        self.health_check = health_check
        self.elb_atts = elb_atts

class ELBAttCrossZoneLoadBalancing(DictLike):
    def __init__(self, enabled = True):
        self.enabled = enabled

    def aws_merge(self, d):
        d['CrossZoneLoadBalancing'] = {'Enabled': self.enabled}

class ELBAttAccessLog(DictLike):
    def __init__(self, s3_bucket_name, s3_bucket_prefix, emit_interval, enabled = True):
        self.enabled = enabled
        self.s3_bucket_name = s3_bucket_name
        self.s3_bucket_prefix = s3_bucket_prefix
        self.emit_interval = emit_interval

    def aws_merge(self, d):
        d['AccessLog'] = {'Enabled': self.enabled,
                          'S3BucketName': self.s3_bucket_name,
                          'EmitInterval': self.emit_interval,
                          'S3BucketPrefix': self.s3_bucket_prefix}

class ELBAttConnectionDraining(DictLike):
    def __init__(self, timeout, enabled = True):
        self.enabled = enabled
        self.timeout = timeout

    def aws_merge(self, d):
        d['ConnectionDraining'] = {'Enabled': self.enabled, Timeout: self.timeout}

class ELBAttIdleTimeout(DictLike):
    def __init__(self, timeout):
        self.timeout = timeout

    def aws_merge(self, d):
        d['ConnectionSettings'] = {'IdleTimeout': self.timeout}

class ELBAtts():
    def __init__(self, *args):
        self.items = []
        for arg in args:
            self.items.append(arg)

    def to_aws(self):
        d = {}
        for att in self.items:
            att.aws_merge(d)
        return d


class ELBListenerConfig(DictLike):
    def __init__(
            self,
            protocol,
            load_balancer_port,
            instance_protocol,
            instance_port,
            ssl_arn):
        self.protocol = protocol
        self.load_balancer_port = load_balancer_port
        self.instance_protocol = instance_protocol
        self.instance_port = instance_port
        self.ssl_arn = ssl_arn

    def to_aws(self):
        l = {'Protocol': self.protocol,
             'LoadBalancerPort': self.load_balancer_port,
             'InstanceProtocol': self.instance_protocol,
             'InstancePort': self.instance_port}
        if self.ssl_arn:
            l['SSLCertificateId'] = self.ssl_arn
        return l


class ELBHealthCheckConfig(DictLike):
    def __init__(
            self,
            target_path,
            target_port,
            target_proto,
            healthy_threshold,
            unhealthy_threshold,
            timeout,
            interval):
        self.target_path = target_path
        self.target_port = target_port
        self.target_proto = target_proto
        self.healthy_threshold = healthy_threshold
        self.unhealthy_threshold = unhealthy_threshold
        self.timeout = timeout
        self.interval = interval


def default_health_check(service_port=443):
    return ELBHealthCheckConfig(
        target_path='/',
        target_port=service_port,
        target_proto='HTTPS',
        healthy_threshold=2,
        unhealthy_threshold=6,
        timeout=5,
        interval=10)


def default_redirector_listener():
    redirector_port = get_redirector_service_nodeport()
    return ELBListenerConfig(
        protocol='TCP',
        load_balancer_port=80,
        instance_protocol='TCP',
        instance_port=redirector_port,
        ssl_arn=None)


def default_service_listener(service_namespace, service_name, ssl_arn):
    service_nodeport = get_service_nodeport(service_namespace, service_name)
    return ELBListenerConfig(
        protocol='HTTPS',
        load_balancer_port=443,
        instance_protocol='HTTP',
        instance_port=service_nodeport,
        ssl_arn=ssl_arn)


def default_elb_config(
        service_namespace,
        service_name,
        vpc_id,
        subnet_ids,
        ssl_arn):
    redirector_listener = default_redirector_listener()
    service_listener = default_service_listener(
        service_namespace, service_name, ssl_arn)
    listeners = [redirector_listener, service_listener]
    health_check = default_health_check(service_listener.instance_port)
    security_groups = [get_elb_access_security_group(vpc_id)]
    tags = [{'Key': 'Stack',
             'Value': service_namespace},
            {'Key': 'KubernetesCluster',
             'Value': get_cluster_name()}]

    return ELBConfig(
        service_namespace,
        listeners,
        security_groups,
        subnet_ids,
        tags,
        health_check)


def default_service_config(
        target_cluster,
        service_namespace,
        service_name,
        vpc_id,
        subnet_ids,
        ssl_arn):
    elb_config = default_elb_config(
        service_namespace,
        service_name,
        vpc_id,
        subnet_ids,
        ssl_arn)
    return ServiceConfig(
        namespace=service_namespace,
        name=service_name,
        target_cluster=target_cluster,
        elb_config=elb_config,
        vpc_id=vpc_id,
        subnet_ids=subnet_ids)


def create_elb(service_config):

    if elb_exists(service_config.elb_config.name):
        print(
            "{} has already been provisioned".format(
                service_config.elb_config.name))
        return
    if get_cluster_name() != service_config.target_cluster:
        print(
            "Currently connected to {} K8s cluster, which is not the target: {}".format(
                get_cluster_name(),
                service_config.target_cluster))
        return

    elb_config = service_config.elb_config
    print("Creating {} ELB".format(elb_config.name))
    response = elb_client.create_load_balancer(
        LoadBalancerName=elb_config.name,
        Listeners=list(map(lambda l: l.to_aws(), elb_config.listeners)),
        SecurityGroups=elb_config.security_groups,
        Subnets=elb_config.subnets,
        Tags=elb_config.tags)
    print("Done")


    if elb_config.elb_atts:
        print("Updating ELB attributes")
        response = elb_client.modify_load_balancer_attributes(
            LoadBalancerName=elb_config.name,
            LoadBalancerAttributes = elb_config.elb_atts.to_aws())
    else:
        print("No ELB attributes defined")

    print("Creating health checks")
    hc = elb_config.health_check
    hc_target = "{}:{}{}".format(
        hc.target_proto,
        hc.target_port,
        hc.target_path)
    response = elb_client.configure_health_check(
        LoadBalancerName=elb_config.name,
        HealthCheck={
            'Target': hc_target,
            'Interval': hc.interval,
            'Timeout': hc.timeout,
            'UnhealthyThreshold': hc.unhealthy_threshold,
            'HealthyThreshold': hc.healthy_threshold
        })
    print("Done")


def attach_elbs_to_asg(asg_name, elb_names):
    response = asg_client.attach_load_balancers(
        AutoScalingGroupName=asg_name,
        LoadBalancerNames=elb_names)
    print(response)


#############

print("Current cluster:", get_cluster_name())

OREGON_B_ASG = 'nodes.oregon-b.moz.works'
## create a bedrock-stage ELB
bedrock_stage = default_service_config(
    target_cluster='oregon-b.moz.works',
    service_namespace='bedrock-stage',
    service_name='bedrock-nodeport',
    vpc_id='vpc-ea93e58f',
    subnet_ids=['subnet-e290afaa'],
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/657b1ca0-8c09-4add-90a2-1243470a6b45')
bedrock_stage.elb_config.elb_atts = ELBAtts(ELBAttIdleTimeout(120))

hc = default_health_check()
hc.target_path = '/healthz/'
#hc.target_port = 32318  # TODO, pull from config above
hc.target_port = get_service_nodeport(bedrock_stage.namespace, bedrock_stage.name)
hc.target_proto = 'HTTP'
bedrock_stage.elb_config.health_check = hc

##  TODO: plan and apply

## 
pp = pprint.PrettyPrinter(indent=2)
pp.pprint(bedrock_stage)

## process all elbs defined aboce
region_elbs = []
region_elbs.append(bedrock_stage)
for elb in region_elbs:
    create_elb(elb)

# finally, attach all the elbs defined above to the ASG
attach_elbs_to_asg(OREGON_B_ASG,
                   list(map(lambda e: e.elb_config.name, region_elbs)))

