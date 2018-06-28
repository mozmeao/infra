from meaoelb.frankfurt import elb_tool


bedrock_dev = elb_tool.define_elb(
    service_namespace='bedrock-dev',
    service_name='bedrock-dev-nodeport',
    # cert needs to be valid for bedrock-dev.frankfurt.moz.works and www-dev.allizom.org
    ssl_arn='arn:aws:acm:eu-central-1:236517346949:certificate/802eee09-7361-4de1-84c3-9704d85b1e2b')
bedrock_dev.elb_config.health_check.target_path = '/healthz/'


elb_tool.show_elbs()
elb_tool.test_elbs()
elb_tool.create_and_bind_elbs()
