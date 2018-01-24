"""
This script iterates through all k8s namespaces and installs a NetworkPolicy
that blocks the AWS metadata service (169.254.0.0/16). Namespaces can
be whitelisted via the WHITELISTED_NAMESPACES list, with kube-system
being whitelisted by default (meaning we don't install this particular
network policy in kube-system, but others may be installed in kube-system
via some other method).
"""

from kubernetes import client, config

WHITELISTED_NAMESPACES = ['kube-system']
AWS_NETWORK_POLICY_NAME = 'block-aws'

config.load_kube_config()

v1 = client.CoreV1Api()
v1beta1 = client.ExtensionsV1beta1Api()
networkingv1 = client.NetworkingV1Api()

namespace_response = v1.list_namespace()
for ns in namespace_response.items:
    name = ns.metadata.name
    print("-> ", name)
    if name in WHITELISTED_NAMESPACES:
        print("\tskipping, ns whitelisted")
        continue

    ns_policy_response = v1beta1.list_namespaced_network_policy(name)
    local_policies = [
        ns_policy.metadata.name for ns_policy in ns_policy_response.items]
    if AWS_NETWORK_POLICY_NAME not in local_policies:
        print("\tnamespace doesn't block AWS")
        md = client.V1ObjectMeta(name=AWS_NETWORK_POLICY_NAME, namespace=name)
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
        response = networkingv1.create_namespaced_network_policy(name, policy)
        print(
            "\tCreated {} in NS {}".format(
                response.metadata.name,
                response.metadata.namespace))
    else:
        print("\tAWS already blocked")
