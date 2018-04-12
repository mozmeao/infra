from meaoelb.elb_tool import ELBTool

AWS_REGION = 'us-west-2'
TARGET_CLUSTER = 'oregon-b.moz.works'
OREGON_B_ASG = "nodes.{}".format(TARGET_CLUSTER)
OREGON_B_VPC = 'vpc-ea93e58f'
OREGON_B_SUBNET_IDS = ['subnet-e290afaa']

# one time setup for all ELBs in this region
# config values here are later used to create default ELB objects that
# can be configured however you like
elb_tool = ELBTool(
    aws_region=AWS_REGION,
    target_cluster=TARGET_CLUSTER,
    asg_name=OREGON_B_ASG,
    vpc_id=OREGON_B_VPC,
    subnet_ids=OREGON_B_SUBNET_IDS)
