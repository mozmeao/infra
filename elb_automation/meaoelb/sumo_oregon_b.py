from meaoelb.oregon_b import elb_tool

# ### SUMO Stage
sumo_stage = elb_tool.define_elb_http(
    service_namespace='sumo-stage',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/192b6409-996e-46ac-a3d9-c78a69670dae')
sumo_stage.elb_config.health_check.target_path = '/healthz/'
sumo_stage.elb_config.name = 'sumo-stage-b'

# ### SUMO prod
sumo_prod = elb_tool.define_elb_http(
    service_namespace='sumo-prod',
    service_name='sumo-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/b427fcf8-4321-41ca-8fe0-57a90da17d52')
sumo_prod.elb_config.health_check.target_path = '/healthz/'
sumo_prod.elb_config.name = 'sumo-prod-b'

# show the ELB's before we process them
# object output is now colorized JSON
elb_tool.show_elbs()

elb_tool.test_elbs()

# if an ELB has already been created, skip and continue on to the next
# This also ensures all ELBs are bound to the ASG
elb_tool.create_and_bind_elbs()
