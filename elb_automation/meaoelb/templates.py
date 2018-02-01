"""
Code generation templates
"""

ELB_LISTENER_CONFIG_TEMPLATE = """
    listeners[{load_balancer_port}] = \\
        ELBListenerConfig(protocol = {protocol},
                        load_balancer_port = {load_balancer_port},
                        instance_protocol = {instance_protocol},
                        instance_port = {instance_port},
                        ssl_arn = {ssl_arn})"""

ELB_HEALTHCHECK_CONFIG_TEMPLATE = """
    hc = ELBHealthCheckConfig(target_path={target_path},
                              target_port={target_port},
                              target_proto={target_proto},
                              healthy_threshold={healthy_threshold},
                              unhealthy_threshold={unhealthy_threshold},
                              timeout={timeout},
                              interval={interval})"""


ELB_ATT_CROSS_ZONE_LOAD_BALANCING_TEMPLATE = """
    att_czlb = ELBAttCrossZoneLoadBalancing(enabled={enabled})"""

ELB_ATT_ACCESS_LOG_TEMPLATE = """
    att_access_log = ELBAttAccessLog(s3_bucket_name={s3_bucket_name},
                                     s3_bucket_prefix={s3_bucket_prefix},
                                     emit_interval={emit_interval},
                                     enabled={enabled})"""

ELB_ATT_CONNECTION_DRAINING = """
    att_conn_draining = ELBAttConnectionDraining(enabled={enabled}, timeout={timeout})"""

ELB_ATT_CONNECTION_SETTINGS = """
    att_conn_settings = ELBAttConnectionSettings(idle_timeout={idle_timeout})"""

ELB_ATTS_TEMPLATE = """
{cross_zone_load_balancing}
{access_log}
{connection_draining}
{connection_settings}
    atts = ELBAtts(cross_zone_load_balancing=att_czlb,
                   access_log=att_access_log,
                   connection_draining=att_conn_draining,
                   connection_settings=att_conn_settings)"""


ELB_CONFIG_TEMPLATE = """
def {method_name}():
    # Health check config
    {health_check}
    # Listener config
    listeners = {{}}
    {listeners}
    # Attributes
    {attributes}
    cfg = ELBConfig(name = {name},
                    listeners = listeners,
                    security_groups = {security_groups},
                    subnets = {subnets},
                    tags = {tags},
                    health_check = hc,
                    elb_atts = atts)
    return cfg
"""

HEADER_TEMPLATE = """
from meaoelb.elb_tool import ELBTool
from meaoelb.config import *
from meaoelb.elb_ctx import ELBContext

AWS_REGION = ''
TARGET_CLUSTER = ''
ASG = "nodes.{}".format(TARGET_CLUSTER)
VPC = ''
SUBNET_IDS = ['']

elb_tool = ELBTool(
    aws_region=AWS_REGION,
    target_cluster=TARGET_CLUSTER,
    asg_name=ASG,
    vpc_id=VPC,
    subnet_ids=SUBNET_IDS)

redirector_port = elb_tool.ctx.get_redirector_service_nodeport()
"""

FOOTER_TEMPLATE = """

# TODO: to automatically assign instance ports to K8s nodeports, replace
# target_port=30150,
#   with
# target_port = elb_tool.ctx.get_service_nodeport(service_namespace, service_name),
#    OR
# target_port = elb_tool.ctx.get_service_nodeport(service_namespace, service_name, "my_nodeport_name"),

# TODO: to use the redirector service nodeport:
# target_port = redirector_port

elb_tool.test_elbs()
"""
