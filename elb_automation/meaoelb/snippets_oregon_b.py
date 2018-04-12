from meaoelb.oregon_b import elb_tool


snippets_stage = elb_tool.define_elb_http(
    service_namespace='snippets-stage',
    service_name='snippets-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/375fd27c-bf20-409d-a48b-4ff0b0fe3658')
snippets_stage.elb_config.elb_atts.connection_settings.idle_timeout = 60
snippets_stage.elb_config.health_check.target_path = '/healthz/'

snippets_prod = elb_tool.define_elb_http(
    service_namespace='snippets-prod',
    service_name='snippets-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/fbe34166-ae87-43f8-b9cc-7bc9a45d904c')
snippets_prod.elb_config.elb_atts.connection_settings.idle_timeout = 60
snippets_prod.elb_config.health_check.target_path = '/healthz/'

snippets_stats = elb_tool.define_elb_http(
    service_namespace='snippets-stats',
    service_name='snippets-stats-nodeport',
    ssl_arn='arn:aws:acm:us-west-2:236517346949:certificate/9c1fa86d-d2da-4d54-b07d-33c200c3a967')
snippets_stats.elb_config.elb_atts.connection_settings.idle_timeout = 60
# snippets-stats does not currently have a /healthz/ endpoint
# elb named 'snippets-stats' already exists for usw cluster
snippets_stats.elb_config.name = 'snippets-stats-b'


# show the ELB's before we process them
# object output is now colorized JSON
elb_tool.show_elbs()

elb_tool.test_elbs()

# create and bind the ELBs
# if an ELB has already been created, skip and continue on to the next
# This also ensures all ELBs are bound to the ASG
elb_tool.create_and_bind_elbs()

# modification example
# elb_tool.modify_elb_attributes({'ConnectionSettings': {'IdleTimeout': 60}})
