import json
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import TerminalFormatter
import re


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
        j = json.dumps(dict(self), indent=2, sort_keys=True)
        print(highlight(j, JsonLexer(), TerminalFormatter()))


class ELBConfig(DictLike):
    def __init__(
            self,
            name,
            listeners,
            security_groups,
            subnets,
            tags,
            health_check,
            elb_atts):
        self.name = name
        self.listeners = listeners
        self.security_groups = security_groups
        self.subnets = subnets
        self.tags = tags
        self.health_check = health_check
        self.elb_atts = elb_atts

    @staticmethod
    def from_aws(elb, aws_atts, tags):
        listeners = {}
        for l in elb['ListenerDescriptions']:
            aws_listener = l['Listener']
            listener = ELBListenerConfig.from_aws(aws_listener)
            listeners[listener.load_balancer_port] = listener
        health_check = ELBHealthCheckConfig.from_aws(elb['HealthCheck'])
        atts = ELBAtts.from_aws(aws_atts)
        return ELBConfig(name=elb['LoadBalancerName'],
                         listeners=listeners,
                         security_groups=elb['SecurityGroups'],
                         subnets=elb['Subnets'],
                         tags=tags,
                         health_check=health_check,
                         elb_atts=atts)


class ELBAttCrossZoneLoadBalancing(DictLike):
    def __init__(self, enabled=False):
        self.enabled = enabled

    def aws_merge(self, d):
        d['CrossZoneLoadBalancing'] = {'Enabled': self.enabled}

    @staticmethod
    def from_aws(obj):
        return ELBAttCrossZoneLoadBalancing(obj['Enabled'])


class ELBAttAccessLog(DictLike):
    def __init__(
            self,
            s3_bucket_name=None,
            s3_bucket_prefix=None,
            emit_interval=None,
            enabled=False):
        self.enabled = enabled
        self.s3_bucket_name = s3_bucket_name
        self.s3_bucket_prefix = s3_bucket_prefix
        self.emit_interval = emit_interval

    def aws_merge(self, d):
        if self.enabled:
            d['AccessLog'] = {'Enabled': self.enabled,
                              'S3BucketName': self.s3_bucket_name,
                              'EmitInterval': self.emit_interval,
                              'S3BucketPrefix': self.s3_bucket_prefix}
        else:
            d['AccessLog'] = {'Enabled': False}

    @staticmethod
    def from_aws(obj):
        return ELBAttAccessLog(
            s3_bucket_name=obj.get('S3BucketName', None),
            s3_bucket_prefix=obj.get('S3BucketPrefix', None),
            emit_interval=obj.get('EmitInterval', None),
            enabled=obj['Enabled'])


class ELBAttConnectionDraining(DictLike):
    def __init__(self, timeout=300, enabled=False):
        self.enabled = enabled
        self.timeout = timeout

    def aws_merge(self, d):
        d['ConnectionDraining'] = {
            'Enabled': self.enabled,
            Timeout: self.timeout}

    @staticmethod
    def from_aws(obj):
        return ELBAttConnectionDraining(enabled=obj['Enabled'],
                                        timeout=obj['Timeout'])


class ELBConnectionSettings(DictLike):
    def __init__(self, idle_timeout=120):
        self.idle_timeout = idle_timeout

    def aws_merge(self, d):
        d['ConnectionSettings'] = {'IdleTimeout': self.idle_timeout}

    @staticmethod
    def from_aws(obj):
        return ELBConnectionSettings(idle_timeout=obj['IdleTimeout'])


class ELBAtts(DictLike):
    def __init__(self):
        self.cross_zone_load_balancing = ELBAttCrossZoneLoadBalancing()
        self.access_log = ELBAttAccessLog()
        self.connection_draining = ELBAttConnectionDraining()
        self.connection_settings = ELBConnectionSettings()

    def to_aws(self):
        d = {}
        self.cross_zone_load_balancing.aws_merge(d)
        self.access_log.aws_merge(d)
        self.connection_draining.aws_merge(d)
        self.connection_settings.aws_merge(d)
        return d

    @staticmethod
    def from_aws(atts):
        newatts = ELBAtts()
        newatts.cross_zone_load_balancing = ELBAttCrossZoneLoadBalancing.from_aws(
            atts['CrossZoneLoadBalancing'])
        newatts.access_log = ELBAttAccessLog.from_aws(atts['AccessLog'])
        newatts.connection_draining = ELBAttConnectionDraining.from_aws(
            atts['ConnectionDraining'])
        newatts.connection_settings = ELBConnectionSettings.from_aws(
            atts['ConnectionSettings'])
        return newatts


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

    @staticmethod
    def from_aws(listener):
        if 'SSLCertificateId' in listener:
            cert_id = listener['SSLCertificateId']
        else:
            cert_id = None

        return ELBListenerConfig(
            protocol=listener['Protocol'],
            load_balancer_port=int(listener['LoadBalancerPort']),
            instance_protocol=listener['InstanceProtocol'],
            instance_port=int(listener['InstancePort']),
            ssl_arn=cert_id)


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

    @staticmethod
    def from_aws(hc):
        #print("Matching ", hc['Target'])
        r = re.compile('([A-Z]+):([0-9]+)(\/.*)')
        matches = r.match(hc['Target'])
        return ELBHealthCheckConfig(
            target_path=matches.group(3),
            target_port=int(matches.group(2)),
            target_proto=matches.group(1),
            healthy_threshold=hc['HealthyThreshold'],
            unhealthy_threshold=hc['UnhealthyThreshold'],
            timeout=hc['Timeout'],
            interval=hc['Interval'])
