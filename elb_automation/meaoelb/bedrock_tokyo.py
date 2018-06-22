from meaoelb.tokyo import elb_tool


bedrock_dev = elb_tool.define_elb(
    service_namespace='bedrock-dev',
    service_name='bedrock-dev-nodeport',
    # cert needs to be valid for bedrock-dev.tokyo.moz.works and www-dev.allizom.org
    ssl_arn='arn:aws:acm:ap-northeast-1:236517346949:certificate/d01eb107-6e73-4781-9736-a6897e3468c9')
bedrock_dev.elb_config.health_check.target_path = '/healthz/'


elb_tool.show_elbs()
elb_tool.test_elbs()
elb_tool.create_and_bind_elbs()
