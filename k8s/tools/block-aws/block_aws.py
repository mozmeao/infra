"""
This script iterates through all k8s namespaces and installs a NetworkPolicy
that blocks the AWS metadata service (169.254.0.0/16). Namespaces can
be whitelisted via the WHITELISTED_NAMESPACES list, with kube-system
being whitelisted by default (meaning we don't install this particular
network policy in kube-system, but others may be installed in kube-system
via some other method).
"""

from collections import defaultdict
import os

from kubernetes import client, config
from munch import munchify
import requests
import sh
import yaml

WHITELISTED_NAMESPACES = os.getenv('WHITELISTED_NAMESPACES',
                                   'kube-system').split(',')
AWS_NETWORK_POLICY_NAME = os.getenv('AWS_NETWORK_POLICY_NAME', 'block-aws')
POLICY_FILENAME = os.getenv('POLICY_FILENAME', 'block-aws-networkpolicy.yaml')
DMS_URL = os.getenv('DMS_URL')
USE_KUBECTL = os.getenv('USE_KUBECTL', True)
IN_CLUSTER = os.getenv('IN_CLUSTER', True)

if IN_CLUSTER:
    config.load_incluster_config()
else:
    config.load_kube_config()


def kubemunch(*args):
    kubectl = sh.kubectl.bake('-o', 'yaml')
    munched = munchify(yaml.load(kubectl(args).stdout))
    if 'items' in munched.keys():
        # override items method
        munched.items = munched['items']
    return munched


def namespace_network_policy_names(use_kubectl=USE_KUBECTL):
    if use_kubectl:
        policies = kubemunch('get', 'netpol', '--all-namespaces').items
    else:
        v1beta1 = client.ExtensionsV1beta1Api()
        policies = v1beta1.list_network_policy_for_all_namespaces().items

    ns_policies = defaultdict(list)
    for policy in policies:
        ns_policies[policy.metadata.namespace].append(policy.metadata.name)
    return ns_policies


def namespaces(use_kubectl=USE_KUBECTL):
    if use_kubectl:
        return [ns.metadata.name for ns in kubemunch('get', 'ns').items]
    else:
        v1 = client.CoreV1Api()
        return [ns.metadata.name for ns in v1.list_namespace().items]


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
    print("\tCreated {} in ns {}".format(response.metadata.name,
                                         response.metadata.namespace))


def ping_dms():
    if DMS_URL:
        print("Notifying DMS")
        r = requests.get(DMS_URL)
        print(r.status_code)
    else:
        print('DMS_URL not found, not notifying DMS')


def main():
    ns_policies = namespace_network_policy_names()
    for namespace in namespaces():
        print("-> ", namespace)
        if namespace in WHITELISTED_NAMESPACES:
            print("\tskipping, ns whitelisted")
        elif AWS_NETWORK_POLICY_NAME not in ns_policies[namespace]:
            create_policy(namespace)
        else:
            print("\tAWS already blocked")
    ping_dms()


if __name__ == '__main__':
    main()
