from meaoelb.elb_tool import ELBTool
from meaoelb.config import ELBAtts, ELBAttIdleTimeout

AWS_REGION = 'us-west-2'
TARGET_CLUSTER = 'oregon-b.moz.works'
OREGON_B_ASG = "nodes.{}".format(TARGET_CLUSTER)
OREGON_B_VPC = 'vpc-ea93e58f'
OREGON_B_SUBNET_IDS = ['subnet-e290afaa']

elb_tool = ELBTool(
    aws_region=AWS_REGION,
    dry_run_mode=True,
    target_cluster=TARGET_CLUSTER,
    asg_name=OREGON_B_ASG,
    vpc_id=OREGON_B_VPC,
    subnet_ids=OREGON_B_SUBNET_IDS)


# Setup ELBs
bedrock_stage = elb_tool.define_elb(
    service_namespace='bedrock-stage',
    service_name='bedrock-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/657b1ca0-8c09-4add-90a2-1243470a6b45')
bedrock_stage.elb_config.elb_atts = ELBAtts(ELBAttIdleTimeout(120))
bedrock_stage.elb_config.health_check.target_path = '/healthz/'
#elb_tool.show_elbs()
#elb_tool.create_elbs()
