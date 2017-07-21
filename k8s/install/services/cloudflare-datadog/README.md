# Cloudflare -> Datadog sync in K8s

## Prereqs:

- set `KUBECONFIG` environment variable
- access to an existing cloudflare-dd-secrets.yaml file, or use `cloudflare-dd-secrets-example.yaml`
as a template from the current directory
- helm/tiller

## Installation

```
export CLOUDFLARE_DD_SECRETS=/full/path/to/cloudflare-dd-secrets.yaml
git clone git@github.com:honestbee/public-charts.git
cd public-charts
git checkout cloudflare-datadog-0.1.0
cd incubator/cloudflare-datadog/

helm install -n cf-dd --namespace cf-dd --debug --dry-run -f ${CLOUDFLARE_DD_SECRETS} .
helm install -n cf-dd --namespace cf-dd -f ${CLOUDFLARE_DD_SECRETS} .
```

---

> Additional info here: https://github.com/mozmeao/cloudflare-datadog/issues/4
