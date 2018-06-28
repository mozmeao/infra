from meaoelb.elb_tool import ELBTool
from meaoelb.config import *
from meaoelb.elb_ctx import ELBContext

AWS_REGION = 'eu-central-1'
TARGET_CLUSTER = 'frankfurt.moz.works'
ASG = "nodes.{}".format(TARGET_CLUSTER)
VPC = 'vpc-4d036a25'
SUBNET_IDS = ['subnet-10685f78']

elb_tool = ELBTool(
    aws_region=AWS_REGION,
    target_cluster=TARGET_CLUSTER,
    asg_name=ASG,
    vpc_id=VPC,
    subnet_ids=SUBNET_IDS)

redirector_port = elb_tool.ctx.get_redirector_service_nodeport()
