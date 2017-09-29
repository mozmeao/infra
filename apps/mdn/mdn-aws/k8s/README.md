# MDN in AWS

## Local Requirements:

- move/copy your K8s configuration file for the Portland cluster to
  `~/.kube/portland.config `

- install j2cli (Jinja2 command-line tool)

```sh
pip install j2cli
```

- install jq (lightweight/flexible command-line JSON processor)

```sh
brew update
brew install jq
```

## Deploying MDN from scratch:

### Provision AWS and Cloud Resources
- Create an AWS RDS MySQL instance
- Create an AWS EFS volume
- Create an AWS SSL certificate
- Create an AWS ElasticCache Redis instance
- Create an AWS ElasticCache Memcached instance
- Create an ElasticCloud (Elasticsearch) instance

### Make the K8s namespace, volumes, and services

This step is only done once, and requires special privileges for creating and
configuring the AWS ELB's that will be created as part of the
`make k8s-services` command.

```sh
cd path/to/the/root/of/your/infra/repo
cd apps/mdn/mdn-aws/k8s
source regions/portland/prod.mdn.moz.works.sh
make k8s-ns
make k8s-shared-storage
make k8s-services
```

### Apply the MDN deployments

- Deploying

```sh
cd path/to/the/root/of/your/infra/repo
cd apps/mdn/mdn-aws/k8s
source regions/portland/prod.mdn.moz.works.sh
export KUMA_IMAGE_TAG=<tag-of-the-kuma-image-you-want-to-deploy>
export KUMASCRIPT_IMAGE_TAG=<tag-of-the-kumascript-image-you-want-to-deploy>
make k8s-deployments
```

## Deploying MDN with an updated Kuma image:

- Rolling-out an update only to the Kuma-based deployments

```sh
cd path/to/the/root/of/your/infra/repo
cd apps/mdn/mdn-aws/k8s
source regions/portland/prod.mdn.moz.works.sh
export KUMA_IMAGE_TAG=<tag-of-the-kuma-image-you-want-to-deploy>
make k8s-kuma-deployments
```

- Rolling-back the previous update to the Kuma-based deployments

```sh
make k8s-kuma-rollback
```

## Deploying MDN with an updated Kumascript image:

- Rolling-out an update only to the Kumascript-based deployments

```sh
cd path/to/the/root/of/your/infra/repo
cd apps/mdn/mdn-aws/k8s
source regions/portland/prod.mdn.moz.works.sh
export KUMASCRIPT_IMAGE_TAG=<tag-of-the-kumascript-image-you-want-to-deploy>
make k8s-kumascript-deployments
```

- Rolling-back the previous update to the Kumascript-based deployments

```sh
make k8s-kumascript-rollback
```

## Deploying MDN with updated images for both Kuma and Kumascript:

- Rolling-out an update to the Kuma and Kumascript-based deployments

```sh
cd path/to/the/root/of/your/infra/repo
cd apps/mdn/mdn-aws/k8s
source regions/portland/prod.mdn.moz.works.sh
export KUMA_IMAGE_TAG=<tag-of-the-kuma-image-you-want-to-deploy>
export KUMASCRIPT_IMAGE_TAG=<tag-of-the-kumascript-image-you-want-to-deploy>
make k8s-deployments
```

- Rolling-back the previous update to the Kuma and Kumascript-based deployments

```sh
make k8s-rollback
```
