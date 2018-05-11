"""
This script generates a .tsv report containing resource requests/limits and deployment HPA
info. It uses kubectl directly.
"""

from collections import defaultdict
import os

from munch import Munch, munchify, unmunchify
import sh
import yaml

SKIP_NAMESPACES = ['kube-system', 'deis']
FIELDS = ['namespace', 'deployment', 'container', 'requests_cpu', 'requests_memory',
          'limits_cpu', 'limits_memory', 'hpa_max_replicas', 'hpa_min_replicas', 'hpa_target_cpu']


def kubemunch(*args):
    kubectl = sh.kubectl.bake('-o', 'yaml')
    out = kubectl(args).stdout
    munched = munchify(yaml.load(out))
    if 'items' in munched.keys():
        # override items method
        munched.items = munched['items']
    return munched


def namespaces():
    return [ns.metadata.name for ns in kubemunch('get', 'ns').items
            if ns.metadata.name not in SKIP_NAMESPACES]


def namespace_deployments(ns):
    return kubemunch('-n', ns, 'get', 'deployments').items


def get_hpa_for_deployment(ns, deployment_name):
    hpas = kubemunch('-n', ns, 'get', 'hpa').items
    return [hpa for hpa in hpas if hpa.spec.scaleTargetRef.name == deployment_name]


def process_requests_and_limits(line, container):
    res = container.resources
    if 'requests' in res:
        line.requests_cpu = res.requests.cpu if 'cpu' in res.requests else None
        line.requests_memory = res.requests.memory if 'memory' in res.requests else None
    if 'limits' in res:
        line.limits_cpu = res.limits.cpu if 'cpu' in res.limits else None
        line.limits_memory = res.limits.memory if 'memory' in res.limits else None


def process_hpas(line, ns, deployment_name):
    hpas = get_hpa_for_deployment(ns, deployment_name)
    if len(hpas) > 1:
        raise Exception("Too many HPAs for deployment")
    elif hpas:
        hpa = hpas[0]
        line.hpa_max_replicas = hpa.spec.maxReplicas
        line.hpa_min_replicas = hpa.spec.minReplicas
        line.hpa_target_cpu = hpa.spec.targetCPUUtilizationPercentage


def main():
    print("\t".join(FIELDS))
    for ns in namespaces():
        deployments = namespace_deployments(ns)
        for deployment in deployments:
            for container in deployment.spec.template.spec.containers:
                line = Munch()
                line.namespace = ns
                line.deployment = deployment.metadata.name
                line.container = container.name

                process_requests_and_limits(line,  container)
                process_hpas(line, ns, deployment.metadata.name)

                line_txt = "\t".join([str(line.get(field, ''))
                                      for field in FIELDS])
                print(line_txt)


if __name__ == '__main__':
    main()
