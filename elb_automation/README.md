# MozMEAO ELB provisioning

## Defining ELBs

ELBs are provisioned per-region (or per-K8s cluster, whatever you like). Each region config is stored in it's own Python 3 file in the `./meaoelb` directory.

### Defining a new region

Create a new .py file in `./meaoelb` named after the region you'd like to define.

For example, here we'll define `meaoelb/oregon-b.py` with the following template:

```python
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
```

### Defining a new ELB in a region

```python
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
# we'll need to add an additional import at the top of the file:
#   from meaoelb.config import ELBAtts, ELBAttIdleTimeout
bedrock_stage.elb_config.elb_atts = ELBAtts(ELBAttIdleTimeout(120))
# custom health check configuration
bedrock_stage.elb_config.health_check.target_path = '/healthz/'
```

### Code to perform ELB creation

```python
# show the ELB's before we process them
elb_tool.show_elbs()
# create and bind the ELBs
# if an ELB has already been created, skip and continue on to the next
# This also ensures all ELBs are bound to the ASG
elb_tool.create_and_bind_elbs()
```

## See changes without applying

    python3 -m meaoelb.oregon_b

## Apply changes

    python3 -m meaoelb.oregon_b
    # you will still be prompted to enter "make it so" before
    # continuing

---

## Generate code for existing ELBs

The `ELBContext` class has a `gen_region()` method on it that will
generate 90% of the code you need to reprovision ELBs. You may wish to 
change port numbers to K8s nodeport lookups, see `meaoelb/ap_northeast_1.py` and `meaoelb/eu_central_1.py` for example code.

```
from meaoelb.elb_ctx import ELBContext

# we don't need to communicate with K8s to generate ELB code
ctx = ELBContext(aws_region = 'eu-central-1', connect_to_k8s = False)
ctx.gen_region()
```

Once the code is generated, you'll need to manually populate the constants at the top of the file:

Example:

```
AWS_REGION = 'ap-northeast-1'
TARGET_CLUSTER = 'tokyo.moz.works'
ASG = "nodes.{}".format(TARGET_CLUSTER)
VPC = 'vpc-cd1f99a9'
SUBNET_IDS = ['subnet-115ed549', 'subnet-ed79369b']
```