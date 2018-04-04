#!/usr/bin/env python3
from kubernetes import client, config
from elbs_for_instance import elbs_for_instance_id

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
    external_id = node.spec.external_id
    elbs = elbs_for_instance_id(external_id)
    node_type = node.metadata.labels['kubernetes.io/role']
    public_ip = get_public_ip(node.status.addresses)

    if elbs:
        print("for ELB in {}; do".format(" ".join(elbs)))
        print("aws elb deregister-instances-from-load-balancer --load-balancer-name"
            " $ELB --instances {} & done".format(external_id))
        print("./elbs_for_instance.py {}".format(external_id))

    print("./upgrade_node.sh {} {}".format(public_ip, node_name))

    if elbs:
        print("for ELB in {}; do".format(" ".join(elbs)))
        print("aws elb register-instances-with-load-balancer --load-balancer-name"
            " $ELB --instances {} & done".format(external_id))
        print("./elbs_for_instance.py {}".format(external_id))

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

