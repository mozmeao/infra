# Cloudflare -> Datadog sync in K8s

## Prereqs:

- set `KUBECONFIG` environment variable
- access to unlocked `ee-infra-private` repo
- helm/tiller

## Installation

```
export EE_INFRA_PRIVATE_PATH=/path/to/ee-infra-private

git clone git@github.com:honestbee/public-charts.git
cd public-charts
git checkout cloudflare-datadog-0.1.0
cd incubator/cloudflare-datadog/

helm install -n cf-dd --namespace cf-dd --debug --dry-run -f ${EE_INFRA_PRIVATE_PATH}/cloudflare-datadog-sync/k8s/cloudflare-dd-secrets.yaml .
helm install -n cf-dd --namespace cf-dd -f ${EE_INFRA_PRIVATE_PATH}/cloudflare-datadog-sync/k8s/cloudflare-dd-secrets.yaml .
```

---

> Additional info here: https://github.com/mozmar/cloudflare-datadog/issues/4