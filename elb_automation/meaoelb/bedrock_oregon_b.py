from meaoelb.oregon_b import elb_tool


bedrock_dev = elb_tool.define_elb(
    service_namespace='bedrock-dev',
    service_name='bedrock-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/21a09f64-2eb3-438c-b6d2-080b07df93d4')
bedrock_dev.elb_config.health_check.target_path = '/healthz/'

bedrock_stage = elb_tool.define_elb(
    service_namespace='bedrock-stage',
    service_name='bedrock-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/657b1ca0-8c09-4add-90a2-1243470a6b45')
# there are more flexible ways of defining ELBS:
# elb_tool.cfg_defaults.default_service_config OR
# elb_tool.cfg_defaults.generic_service_config
# but elb_tool.define_elb() fills in most of the blanks for you

# add an IdleTimeout as an ELB attribute
# custom health check configuration
bedrock_stage.elb_config.health_check.target_path = '/healthz/'

elb_tool.show_elbs()
elb_tool.test_elbs()
elb_tool.create_and_bind_elbs()
