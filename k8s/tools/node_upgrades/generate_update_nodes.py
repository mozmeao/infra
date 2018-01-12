from kubernetes import client, config

# specify context in the next method call if desired
config.load_kube_config()

v1 = client.CoreV1Api()

def get_public_ip(addresses):
    public_ip = [a.address for a in addresses if a.type == 'ExternalIP']
    if len(public_ip) != 1:
        raise Exception("Can't find public ip in", addresses)
    return public_ip[0]

def format_node_command(node):
    node_name = node.metadata.name
    node_type = node.metadata.labels['kubernetes.io/role']
    public_ip = get_public_ip(node.status.addresses)
    print("./upgrade_node.sh {} {};".format(public_ip, node_name))

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

