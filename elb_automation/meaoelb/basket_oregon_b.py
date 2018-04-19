from meaoelb.oregon_b import elb_tool

basket_dev = elb_tool.define_elb_http(
    service_namespace='basket-dev',
    service_name='basket-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/9bc81da3-4d50-420f-bad1-b33ff9545c98')
basket_dev.elb_config.health_check.target_path = '/healthz/'
basket_dev.elb_config.elb_atts.connection_settings.idle_timeout = 60

basket_stage = elb_tool.define_elb_http(
    service_namespace='basket-stage',
    service_name='basket-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/3a319919-5568-4c06-a351-4cd27baeb29f')
basket_stage.elb_config.health_check.target_path = '/healthz/'
basket_stage.elb_config.elb_atts.connection_settings.idle_timeout = 60

basket_admin_stage = elb_tool.define_elb_http(
    service_namespace='basket-admin-stage',
    service_name='basket-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/3a319919-5568-4c06-a351-4cd27baeb29f')
basket_admin_stage.elb_config.health_check.target_path = '/healthz/'
basket_admin_stage.elb_config.elb_atts.connection_settings.idle_timeout = 60

basket_prod = elb_tool.define_elb_http(
    service_namespace='basket-prod',
    service_name='basket-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/385ce81c-80de-4ec9-865f-3b9a119139ed')
basket_prod.elb_config.health_check.target_path = '/healthz/'
basket_prod.elb_config.elb_atts.connection_settings.idle_timeout = 60

basket_admin = elb_tool.define_elb_http(
    service_namespace='basket-admin',
    service_name='basket-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/a6ddbe25-f5a0-4c2e-aa7f-02c328e30526')
basket_admin.elb_config.health_check.target_path = '/healthz/'
basket_admin.elb_config.elb_atts.connection_settings.idle_timeout = 60

elb_tool.show_elbs()
elb_tool.test_elbs()
elb_tool.create_and_bind_elbs()
