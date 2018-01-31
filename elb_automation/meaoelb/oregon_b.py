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

### Bedrock Stage
# Define ELB's that we'd like to have created
bedrock_stage = elb_tool.define_elb(
    service_namespace='bedrock-stage',
    service_name='bedrock-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/657b1ca0-8c09-4add-90a2-1243470a6b45')
# there are more flexible ways of defining ELBS:
# elb_tool.cfg_defaults.default_service_config OR
# elb_tool.cfg_defaults.generic_service_config
# but elb_tool.define_elb() fills in most of the blanks for you

# add an IdleTimeout as an ELB attribute
bedrock_stage.elb_config.elb_atts.connection_settings.idle_timeout = 120
# custom health check configuration
bedrock_stage.elb_config.health_check.target_path = '/healthz/'


# ### Bedrock Dev
bedrock_dev = elb_tool.define_elb_http(
    service_namespace='bedrock-dev',
    service_name='bedrock-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/657b1ca0-8c09-4add-90a2-1243470a6b45')
bedrock_dev.elb_config.elb_atts.connection_settings.idle_timeout = 120
bedrock_dev.elb_config.health_check.target_path = '/healthz/'


# show the ELB's before we process them
# object output is now colorized JSON
#elb_tool.show_elbs()

# create and bind the ELBs
# if an ELB has already been created, skip and continue on to the next
# This also ensures all ELBs are bound to the ASG
elb_tool.create_and_bind_elbs()
