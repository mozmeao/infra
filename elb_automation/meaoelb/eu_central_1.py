
from meaoelb.elb_tool import ELBTool
from meaoelb.config import *
from meaoelb.elb_ctx import ELBContext

AWS_REGION = 'eu-central-1'
TARGET_CLUSTER = 'frankfurt.moz.works'
ASG = "nodes.{}".format(TARGET_CLUSTER)
VPC = 'vpc-4d036a25'
SUBNET_IDS = ['subnet-10685f78', 'subnet-57ef9f2d']

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
                              target_port=http_nodeport,
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
                          instance_port=http_nodeport,
                          ssl_arn=None)
    listeners[9090] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=9090,
                          instance_protocol='TCP',
                          instance_port=healthz_nodeport,
                          ssl_arn=None)
    listeners[443] = ELBListenerConfig(
        protocol='SSL',
        load_balancer_port=443,
        instance_protocol='TCP',
        instance_port=https_nodeport,
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/79885752-992b-48a4-8170-22475cac599e')
    listeners[2222] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=2222,
                          instance_protocol='TCP',
                          instance_port=builder_nodeport,
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
    cfg = ELBConfig(name='a82511f724fb611e78dc902859405480',
                    listeners=listeners,
                    security_groups=['sg-8d1064e6'],
                    subnets=['subnet-10685f78'],
                    tags=[{'Key': 'kubernetes.io/service-name',
                           'Value': 'deis/deis-router'},
                          {'Key': 'KubernetesCluster',
                           'Value': 'frankfurt.moz.works'},
                          {'Key': 'kubernetes.io/cluster/frankfurt.moz.works',
                           'Value': 'owned'}],
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/eac03015-d53b-42f2-84e9-2b58a0231e8b')
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/fa2169bd-cd78-4024-adf2-659424de6b45')
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
                    tags=[],
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/c92264e0-d477-417e-ab3b-fc15c65a574e')
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/79885752-992b-48a4-8170-22475cac599e')
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
                    tags=[],
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/79885752-992b-48a4-8170-22475cac599e')
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/290a91d7-4f69-4791-b670-534b671bd6b8')
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
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_nucleus_prod():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'nucleus-prod', 'nucleus-nodeport', 'https')
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
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/9a38de62-3461-43a4-9027-4ec5d165e0d6')
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
    cfg = ELBConfig(name='nucleus-prod',
                    listeners=listeners,
                    security_groups=['sg-02552a69'],
                    subnets=['subnet-10685f78'],
                    tags=[],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_mdn_dev():
    # Health check config

    hc = ELBHealthCheckConfig(target_path=None,
                              target_port=31616,
                              target_proto='TCP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[443] = ELBListenerConfig(
        protocol='HTTPS',
        load_balancer_port=443,
        instance_protocol='HTTP',
        instance_port=31616,
        ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/8e3c817f-dec5-4ab7-9bdf-38f731c8ee4e')
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
    cfg = ELBConfig(name='a37e4a92db2a611e78dc902859405480',
                    listeners=listeners,
                    security_groups=['sg-46b6642c'],
                    subnets=['subnet-10685f78'],
                    tags=[{'Key': 'kubernetes.io/service-name',
                           'Value': 'mdn-prod/web'},
                          {'Key': 'KubernetesCluster',
                           'Value': 'frankfurt.moz.works'},
                          {'Key': 'kubernetes.io/cluster/frankfurt.moz.works',
                           'Value': 'owned'}],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


def define_openvpn():
    nodeport = elb_tool.ctx.get_service_nodeport(
        'openvpn', 'yummy-armadillo-openvpn', 'openvpn')
    # Health check config

    hc = ELBHealthCheckConfig(target_path=None,
                              target_port=nodeport,
                              target_proto='TCP',
                              healthy_threshold=2,
                              unhealthy_threshold=6,
                              timeout=5,
                              interval=10)
    # Listener config
    listeners = {}

    listeners[443] = \
        ELBListenerConfig(protocol='TCP',
                          load_balancer_port=443,
                          instance_protocol='TCP',
                          instance_port=nodeport,
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
    cfg = ELBConfig(name='aebf2210abda911e78dc902859405480',
                    listeners=listeners,
                    security_groups=['sg-82c16be8'],
                    subnets=['subnet-10685f78'],
                    tags=[{'Key': 'kubernetes.io/service-name',
                           'Value': 'openvpn/yummy-armadillo-openvpn'},
                          {'Key': 'KubernetesCluster',
                           'Value': 'frankfurt.moz.works'},
                          {'Key': 'kubernetes.io/cluster/frankfurt.moz.works',
                           'Value': 'owned'}],
                    health_check=hc,
                    elb_atts=atts)
    return cfg


elb_tool.define_generic_elb(define_deis_router())
elb_tool.define_generic_elb(define_basket_prod())
elb_tool.define_generic_elb(define_basket_stage())
elb_tool.define_generic_elb(define_snippets())
elb_tool.define_generic_elb(define_careers())
elb_tool.define_generic_elb(define_bedrock_prod())
elb_tool.define_generic_elb(define_bedrock_stage())
elb_tool.define_generic_elb(define_snippets_stats())
elb_tool.define_generic_elb(define_nucleus_prod())
elb_tool.define_generic_elb(define_mdn_dev())
elb_tool.define_generic_elb(define_openvpn())


## 2018 load balancers
sumo_dev_frankfurt = elb_tool.define_elb_http(
    service_namespace='sumo-dev',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/6bf2d490-690a-476e-992b-c9ad73488d2f')
sumo_dev_frankfurt.elb_config.health_check.target_path = '/healthz/'

sumo_stage_frankfurt = elb_tool.define_elb_http(
    service_namespace='sumo-stage',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/b74e73f7-6fd7-4fea-99fa-c67e34556077')
sumo_stage_frankfurt.elb_config.health_check.target_path = '/healthz/'

sumo_prod_frankfurt = elb_tool.define_elb_http(
    service_namespace='sumo-prod',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/88ff1ddb-7a2f-4a78-85b3-cdcc0ea97124')
sumo_prod_frankfurt.elb_config.health_check.target_path = '/healthz/'


elb_tool.test_elbs()
elb_tool.create_and_bind_elbs()
