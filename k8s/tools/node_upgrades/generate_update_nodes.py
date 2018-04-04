from kubernetes import client, config
import boto3

# specify context in the next method call if desired
config.load_kube_config()

v1 = client.CoreV1Api()

# TODO: hardcoded region
autoscaling_client = boto3.client('autoscaling', region_name='us-west-2')
ec2_client = boto3.client('ec2', region_name='us-west-2')
elb_client = boto3.client('elb', region_name='us-west-2')


def elbs_for_instance_id(instance_id):
  elbs = elb_client.describe_load_balancers()
  all_names = []
  for elb in elbs['LoadBalancerDescriptions']:
    #print(elb['LoadBalancerName'])
    iids = [i['InstanceId'] for i in elb['Instances']]
    if instance_id in iids:
      all_names.append(elb['LoadBalancerName'])	
  return all_names

def get_public_ip(addresses):
    public_ip = [a.address for a in addresses if a.type == 'ExternalIP']
    if len(public_ip) != 1:
        raise Exception("Can't find public ip in", addresses)
    return public_ip[0]

def format_node_command(node):
    node_name = node.metadata.name
    external_id = node.spec.external_id
    elbs = elbs_for_instance_id(external_id)
    node_type = node.metadata.labels['kubernetes.io/role']
    public_ip = get_public_ip(node.status.addresses)

    for elb in elbs:
      print("aws elb deregister-instances-from-load-balancer --load-balancer-name {} --instances {}".format(elb, external_id))

    print("./upgrade_node.sh {} {}".format(public_ip, node_name))
    for elb in elbs:
      print("rereg {}".format(elb))

    print("-"*50)

nodes_response = v1.list_node()

print("# Workers:")
workers = [n for n in nodes_response.items if n.metadata.labels['kubernetes.io/role'] == 'node']
for node in workers:
    format_node_command(node)    

print("#" * 50)
print("# Masters:")
masters = [n for n in nodes_response.items if n.metadata.labels['kubernetes.io/role'] == 'master']
for node in masters:
    format_node_command(node)    

