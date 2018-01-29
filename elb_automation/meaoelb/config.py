import pprint


class DictLike(dict):
    def __getattr__(self, key):
        return self[key]

    def __setattr__(self, key, value):
        self[key] = value


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

    def show(self):
        pp = pprint.PrettyPrinter(indent=2)
        print("-" * 50)
        print("ELB: {}".format(self.elb_config.name))
        pp.pprint(self)


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
    def __init__(self, enabled=True):
        self.enabled = enabled

    def aws_merge(self, d):
        d['CrossZoneLoadBalancing'] = {'Enabled': self.enabled}


class ELBAttAccessLog(DictLike):
    def __init__(
            self,
            s3_bucket_name,
            s3_bucket_prefix,
            emit_interval,
            enabled=True):
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
    def __init__(self, timeout, enabled=True):
        self.enabled = enabled
        self.timeout = timeout

    def aws_merge(self, d):
        d['ConnectionDraining'] = {
            'Enabled': self.enabled,
            Timeout: self.timeout}


class ELBAttIdleTimeout(DictLike):
    def __init__(self, timeout):
        self.timeout = timeout

    def aws_merge(self, d):
        d['ConnectionSettings'] = {'IdleTimeout': self.timeout}


class ELBAtts():
    def __init__(self, *args):
        self.items = []
        self.items = list(args)

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
