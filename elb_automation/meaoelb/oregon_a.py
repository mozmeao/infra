from meaoelb.elb_tool import ELBTool

AWS_REGION = 'us-west-2'
TARGET_CLUSTER = 'oregon-a.moz.works'
OREGON_A_ASG = "nodes.{}".format(TARGET_CLUSTER)
OREGON_A_VPC = 'vpc-ea93e58f'
OREGON_A_SUBNET_IDS = ['subnet-0d89cd37ecec22dd2']

elb_tool = ELBTool(
    aws_region=AWS_REGION,
    target_cluster=TARGET_CLUSTER,
    asg_name=OREGON_A_ASG,
    vpc_id=OREGON_A_VPC,
    subnet_ids=OREGON_A_SUBNET_IDS)


sumo_stage = elb_tool.define_elb_http(
    service_namespace='sumo-stage',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/0a683933-3b11-4651-bf48-4fd8097d6b64')
sumo_stage.elb_config.health_check.target_path = '/healthz/'
sumo_stage.elb_config.name = 'sumo-stage-a'

sumo_prod = elb_tool.define_elb_http(
    service_namespace='sumo-prod',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/0a683933-3b11-4651-bf48-4fd8097d6b64')
sumo_prod.elb_config.health_check.target_path = '/healthz/'
sumo_prod.elb_config.name = 'sumo-prod-a'


elb_tool.show_elbs()
elb_tool.test_elbs()
elb_tool.create_and_bind_elbs()
