
from meaoelb.elb_tool import ELBTool
from meaoelb.config import *
from meaoelb.elb_ctx import ELBContext

AWS_REGION = 'ap-northeast-1'
TARGET_CLUSTER = 'tokyo.moz.works'
ASG = "nodes.{}".format(TARGET_CLUSTER)
VPC = 'vpc-cd1f99a9'
SUBNET_IDS = ['subnet-115ed549', 'subnet-ed79369b']

elb_tool = ELBTool(
    aws_region=AWS_REGION,
    target_cluster=TARGET_CLUSTER,
    asg_name=ASG,
    vpc_id=VPC,
    subnet_ids=SUBNET_IDS)

redirector_port = elb_tool.ctx.get_redirector_service_nodeport()


def define_deis_router():

    http_nodeport = elb_tool.ctx.get_service_nodeport(
        'deis', 'deis-router', 'http')
    healthz_nodeport = elb_tool.ctx.get_service_nodeport(
        'deis', 'deis-router', 'healthz')
    https_nodeport = elb_tool.ctx.get_service_nodeport(
        'deis', 'deis-router', 'https')
    builder_nodeport = elb_tool.ctx.get_service_nodeport(
        'deis', 'deis-router', 'builder')
    # Health check config

    hc = ELBHealthCheckConfig(target_path=None,
                              target_port=30150,
                              target_proto='TCP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=30150,
                          ssl_arn=None)
    listeners[9090] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=9090,
                          instance_protocol='TCP',
                          instance_port=31986,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=31882,
        ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/a2a637ae-52bf-421d-bc95-6aa20eda649f')
    listeners[2222] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=2222,
                          instance_protocol='TCP',
                          instance_port=32560,
                          ssl_arn=None)
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=False)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=False, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=1200)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='a63990d51037511e7845b06353bb5962',
                    listeners=listeners,
                    security_groups=['sg-cf763da8'],
                    subnets=['subnet-ed79369b'],
                    tags=[{'Key': 'kubernetes.io/service-name',
                           'Value': 'deis/deis-router'},
                          {'Key': 'KubernetesCluster',
                           'Value': 'tokyo.moz.works'}],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_snippets():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'snippets-prod', 'snippets-nodeport', 'https')

    # Health check config
    hc = ELBHealthCheckConfig(target_path='/healthz/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=nodeport,
        ssl_arn='arn:aws:iam::236517346949:server-certificate/snippets.mozilla.com')
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='snippets',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_careers():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'careers-prod', 'careers-nodeport', 'https')

    # Health check config

    hc = ELBHealthCheckConfig(target_path='/healthz/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=nodeport,
        ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/1063b46f-9755-47a1-9c26-ede6c66d810d')

    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='careers',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_snippets_stats():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'snippets-stats', 'snippets-stats-nodeport', 'https')

    # Health check config

    hc = ELBHealthCheckConfig(target_path='/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=nodeport,
        ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/3fd8337d-9476-46a9-acda-47abc3b95472')
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='snippets-stats',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_mdn_dev():
    # TODO: DECOM this, it's probably unused!

    # Health check config

    hc = ELBHealthCheckConfig(target_path=None,
                              target_port=30420,
                              target_proto='TCP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=30420,
                          ssl_arn=None)
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=False)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=False, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='a09c0082826ea11e7845b06353bb5962',
                    listeners=listeners,
                    security_groups=['sg-2bbcaa4c'],
                    subnets=['subnet-ed79369b'],
                    tags=[{'Key': 'kubernetes.io/service-name',
                           'Value': 'mdn-dev/web'},
                          {'Key': 'KubernetesCluster',
                           'Value': 'tokyo.moz.works'}],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_bedrock_stage():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'bedrock-stage', 'bedrock-nodeport', 'https')

    # Health check config

    hc = ELBHealthCheckConfig(target_path='/healthz/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='HTTP',
                          load_balancer_port=80,
                          instance_protocol='HTTP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='HTTPS',
        load_balancer_port=443,
        instance_protocol='HTTP',
        instance_port=nodeport,
        ssl_arn='arn:aws:iam::236517346949:server-certificate/wildcard.allizom.org_20180103')
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='bedrock-stage',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_bedrock_prod():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'bedrock-prod', 'bedrock-nodeport', 'https')

    # Health check config

    hc = ELBHealthCheckConfig(target_path='/healthz/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='HTTP',
                          load_balancer_port=80,
                          instance_protocol='HTTP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='HTTPS',
        load_balancer_port=443,
        instance_protocol='HTTP',
        instance_port=nodeport,
        ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/099d5838-a413-478a-abc1-afb67c4017f1')
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='bedrock-prod',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_basket_stage():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'basket-stage', 'basket-nodeport', 'http')
    # Health check config

    hc = ELBHealthCheckConfig(target_path='/healthz/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=nodeport,
        ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/f2f3eb0a-c9c9-4404-b89d-16d3e47b8bcc')
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='basket-stage',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_basket_prod():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'basket-prod', 'basket-nodeport', 'http')

    # Health check config

    hc = ELBHealthCheckConfig(target_path='/healthz/',
                              target_port=nodeport,
                              target_proto='HTTP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[80] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=80,
                          instance_protocol='TCP',
                          instance_port=redirector_port,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=nodeport,
        ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/9c13521f-c93e-42f0-b969-b11fd571ff91')
    # Attributes

    att_czlb = ELBAttCrossZoneLoadBalancing(enabled=True)

    att_access_log = ELBAttAccessLog(s3_bucket_name=None,
                                     s3_bucket_prefix=None,
                                     emit_interval=None,
                                     enabled=False)

    att_conn_draining = ELBAttConnectionDraining(enabled=True, timeout=300)

    att_conn_settings = ELBAttConnectionSettings(idle_timeout=60)
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)
    cfg = ELBConfig(name='basket-prod',
                    listeners=listeners,
                    security_groups=['sg-ac070bcb'],
                    subnets=['subnet-ed79369b'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


elb_tool.define_generic_elb(define_deis_router())
elb_tool.define_generic_elb(define_snippets())
elb_tool.define_generic_elb(define_careers())
elb_tool.define_generic_elb(define_snippets_stats())
elb_tool.define_generic_elb(define_mdn_dev())
elb_tool.define_generic_elb(define_bedrock_stage())
elb_tool.define_generic_elb(define_bedrock_prod())
elb_tool.define_generic_elb(define_basket_stage())
elb_tool.define_generic_elb(define_basket_prod())


# TODO: to automatically assign instance ports to K8s nodeports, replace
# target_port=30150,
#   with
# target_port = elb_tool.ctx.get_service_nodeport(service_namespace, service_name),
#    OR
# target_port = elb_tool.ctx.get_service_nodeport(service_namespace, service_name, "my_nodeport_name"),

# TODO: to use the redirector service nodeport:
# target_port = redirector_port

elb_tool.test_elbs()
