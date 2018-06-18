# Recoving a failed K8s master

### Scenario

When a K8s master instance is terminated, DNS must be manually updated to point at the new master internal and external IPs. This is a kops bug, as described in [this issue](https://github.com/kubernetes/kops/issues/2634).

- External API access (`kubectl`) uses `api.CLUSTER.moz.works.`
    - ex: `api.tokyo.moz.works.`

> If running a `kubectl` command times out after a master instance has been recreated (and firewalling is not an issue), ensure that the `api.CLUSTER.moz.works.` value is correct.

- Worker nodes communicate with K8s via the `api.internal.CLUSTER.moz.works.`
    - ex: `api.internal.tokyo.moz.works.`

> If running `kubectl get nodes` shows worker nodes in unknown state, ensure the `api.internal.CLUSTER.moz.works.` value is correct.


### Updating DNS

1. Update the `api.internal.CLUSTER.moz.works.` record to the new *internal* IP of the master.

2. Update the`api.CLUSTER.moz.works.` record to the new *external* IP of the master.
