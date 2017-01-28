# Tools

### `k8s_ssh_security.ssh`

This script grants or revokes SSH access to a kops Kubernetes cluster.

```
~/infra/k8s/tools$ ./k8s_ssh_security.sh --help
---------------------------------------------
You must source config.sh to use this script.

Show current security groups
k8s_ssh_security.sh --show

Disable external ssh into K8s:
k8s_ssh_security.sh --disable

Disable ssh access from this public ip into K8s:
k8s_ssh_security.sh --disable --myip

Enable 0.0.0.0/0 ssh access into K8s:
k8s_ssh_security.sh --enable

Enable ssh access from this public ip into K8s:
k8s_ssh_security.sh --enable --myip
```

