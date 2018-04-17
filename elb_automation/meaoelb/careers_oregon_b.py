from meaoelb.oregon_b import elb_tool

careers_stage = elb_tool.define_elb_http(
    service_namespace='careers-stage',
    service_name='careers-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/4952e9c1-dda2-450b-b156-908a42869f4f')
careers_stage.elb_config.health_check.target_path = '/healthz/'

careers_prod = elb_tool.define_elb_http(
    service_namespace='careers-prod',
    service_name='careers-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/1bf60ff2-141f-4f9c-a3b0-e3391cdf6994')
careers_prod.elb_config.health_check.target_path = '/healthz/'

# show the ELB's before we process them
# object output is now colorized JSON
elb_tool.show_elbs()

elb_tool.test_elbs()

# if an ELB has already been created, skip and continue on to the next
# This also ensures all ELBs are bound to the ASG
elb_tool.create_and_bind_elbs()
