import json
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import TerminalFormatter
import re
from meaoelb.templates import *


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

    def gen_code(self):
        """
        Generate Python code to automate an ELB config
        """
        hc = self.health_check.gen_code()
        atts = self.elb_atts.gen_code()
        listener_txt = ""

        for (lport, lvalue) in self.listeners.items():
            listener_txt += lvalue.gen_code()
        # this obviously won't convert all characters, but will get us most of
        # the way
        method_name = "define_{}".format(self.name.replace('-', '_'))

        code = ELB_CONFIG_TEMPLATE.format(
            name=repr(self.name),
            security_groups=self.security_groups,
            subnets=self.subnets,
            tags=self.tags,
            attributes=atts,
            health_check=hc,
            listeners=listener_txt,
            method_name=method_name)
        return (code, method_name)


class ELBAttCrossZoneLoadBalancing(DictLike):
    def __init__(self, enabled=False):
        self.enabled = enabled

    def aws_merge(self, d):
        d['CrossZoneLoadBalancing'] = {'Enabled': self.enabled}

    @staticmethod
    def from_aws(obj):
        return ELBAttCrossZoneLoadBalancing(obj['Enabled'])

    def gen_code(self):
        return ELB_ATT_CROSS_ZONE_LOAD_BALANCING_TEMPLATE.format(
            enabled=self.enabled)


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

    def gen_code(self):
        return ELB_ATT_ACCESS_LOG_TEMPLATE.format(
            enabled=self.enabled,
            s3_bucket_name=repr(self.s3_bucket_name),
            s3_bucket_prefix=repr(self.s3_bucket_prefix),
            emit_interval=self.emit_interval)


class ELBAttConnectionDraining(DictLike):
    def __init__(self, timeout=300, enabled=False):
        self.enabled = enabled
        self.timeout = timeout

    def aws_merge(self, d):
        d['ConnectionDraining'] = {
            'Enabled': self.enabled,
            'Timeout': self.timeout}

    @staticmethod
    def from_aws(obj):
        return ELBAttConnectionDraining(enabled=obj['Enabled'],
                                        timeout=obj['Timeout'])

    def gen_code(self):
        return ELB_ATT_CONNECTION_DRAINING.format(
            enabled=self.enabled,
            timeout=self.timeout)


class ELBAttConnectionSettings(DictLike):
    def __init__(self, idle_timeout=120):
        self.idle_timeout = idle_timeout

    def aws_merge(self, d):
        d['ConnectionSettings'] = {'IdleTimeout': self.idle_timeout}

    @staticmethod
    def from_aws(obj):
        return ELBAttConnectionSettings(idle_timeout=obj['IdleTimeout'])

    def gen_code(self):
        return ELB_ATT_CONNECTION_SETTINGS.format(
            idle_timeout=self.idle_timeout)


class ELBAtts(DictLike):
    def __init__(self,
                 cross_zone_load_balancing=ELBAttCrossZoneLoadBalancing(),
                 access_log=ELBAttAccessLog(),
                 connection_draining=ELBAttConnectionDraining(),
                 connection_settings=ELBAttConnectionSettings()):

        self.cross_zone_load_balancing = cross_zone_load_balancing
        self.access_log = access_log
        self.connection_draining = connection_draining
        self.connection_settings = connection_settings

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
        newatts.connection_settings = ELBAttConnectionSettings.from_aws(
            atts['ConnectionSettings'])
        return newatts

    def gen_code(self):
        return ELB_ATTS_TEMPLATE.format(
            cross_zone_load_balancing=self.cross_zone_load_balancing.gen_code(),
            access_log=self.access_log.gen_code(),
            connection_draining=self.connection_draining.gen_code(),
            connection_settings=self.connection_settings.gen_code())


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

    def gen_code(self):
        return ELB_LISTENER_CONFIG_TEMPLATE.format(
            load_balancer_port=self.load_balancer_port,
            protocol=repr(self.protocol),
            instance_protocol=repr(self.instance_protocol),
            instance_port=self.instance_port,
            ssl_arn=repr(self.ssl_arn))


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
        r = re.compile('([A-Z]+):([0-9]+)(\/.*)?')
        matches = r.match(hc['Target'])
        return ELBHealthCheckConfig(
            target_path=matches.group(3),
            target_port=int(matches.group(2)),
            target_proto=matches.group(1),
            healthy_threshold=hc['HealthyThreshold'],
            unhealthy_threshold=hc['UnhealthyThreshold'],
            timeout=hc['Timeout'],
            interval=hc['Interval'])

    def gen_code(self):
        return ELB_HEALTHCHECK_CONFIG_TEMPLATE.format(
            target_path=repr(self.target_path),
            target_port=self.target_port,
            target_proto=repr(self.target_proto),
            healthy_threshold=self.healthy_threshold,
            unhealthy_threshold=self.unhealthy_threshold,
            timeout=self.timeout,
            interval=self.interval)
