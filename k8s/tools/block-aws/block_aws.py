"""
This script iterates through all k8s namespaces and installs a NetworkPolicy
that blocks the AWS metadata service (169.254.0.0/16). Namespaces can
be whitelisted via the WHITELISTED_NAMESPACES list, with kube-system
being whitelisted by default (meaning we don't install this particular
network policy in kube-system, but others may be installed in kube-system
via some other method).
"""

import os

from kubernetes import client, config
from munch import munchify
import requests
import sh
import yaml

WHITELISTED_NAMESPACES = ['kube-system']
AWS_NETWORK_POLICY_NAME = 'block-aws'
POLICY_FILENAME = 'block-aws-networkpolicy.yaml'
USE_KUBECTL = os.getenv('USE_KUBECTL', True)
IN_CLUSTER = os.getenv('IN_CLUSTER', True)

if IN_CLUSTER:
    config.load_incluster_config()
else:
    config.load_kube_config()


def kubemunch(*args):
    kubectl_yaml = sh.kubectl.bake('-o', 'yaml')
    munched = munchify(yaml.load(kubectl_yaml(args).stdout))
    if 'items' in munched.keys():
        # override items method
        munched.items = munched['items']
    return munched


def namespaces(use_kubectl=USE_KUBECTL):
    if use_kubectl:
        return [ns.metadata.name for ns in kubemunch('get', 'ns').items]
    else:
        v1 = client.CoreV1Api()
        return [ns.metadata.name for ns in v1.list_namespace()]


def network_policies(namespace, use_kubectl=USE_KUBECTL):
    if use_kubectl:
        ns_policies = kubemunch('get', 'networkpolicy', '-n', namespace)
    else:
        v1beta1 = client.ExtensionsV1beta1Api()
        ns_policies = v1beta1.list_namespaced_network_policy(namespace)
    return [ns_policy.metadata.name for ns_policy in ns_policies.items]


def create_policy(namespace, use_kubectl=USE_KUBECTL):
    if use_kubectl:
        response = kubemunch('create', '-n', namespace, '-f', POLICY_FILENAME)
    else:
        md = client.V1ObjectMeta(name=AWS_NETWORK_POLICY_NAME,
                                 namespace=namespace)
        match_expression = client.V1LabelSelectorRequirement(
            key='k8s-app', operator='DoesNotExist')
        pod_selector = client.V1LabelSelector(
            match_expressions=[match_expression])

        ip_block = client.V1beta1IPBlock(
            cidr='0.0.0.0/0', _except=['169.254.0.0/16'])
        peer = client.V1beta1NetworkPolicyPeer(ip_block=ip_block)
        egress = client.V1beta1NetworkPolicyEgressRule(to=[peer])
        spec = client.V1beta1NetworkPolicySpec(
            pod_selector=pod_selector,
            egress=[egress],
            policy_types=['Egress'])
        policy = client.V1beta1NetworkPolicy(metadata=md, spec=spec)
        networkingv1 = client.NetworkingV1Api()
        response = networkingv1.create_namespaced_network_policy(namespace,
                                                                 policy)
    print(
        "\tCreated {} in NS {}".format(
            response.metadata.name,
            response.metadata.namespace))


def ping_dms():
    if 'DMS_URL' in os.environ:
        print("Notifying DMS")
        r = requests.get(os.environ['DMS_URL'])
        print(r.status_code)
    else:
        print('DMS_URL not found, not notifying DMS')


def main():
    for namespace in namespaces():
        print("-> ", namespace)
        if namespace in WHITELISTED_NAMESPACES:
            print("\tskipping, ns whitelisted")
            continue

        local_policies = network_policies(namespace)
        if AWS_NETWORK_POLICY_NAME not in local_policies:
            create_policy(namespace)
        else:
            print("\tAWS already blocked")
    ping_dms()


if __name__ == '__main__':
    main()
