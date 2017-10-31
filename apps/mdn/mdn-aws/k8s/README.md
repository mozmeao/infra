# MDN in AWS

## Local Requirements:

- Install j2cli (Jinja2 command-line tool)
```sh
pip install j2cli
```

- Install jq (lightweight/flexible command-line JSON processor)
```sh
brew update
brew install jq
```

- Move/copy your K8s configuration file for the Portland cluster to `~/.kube/portland.config`

## Deploying MDN

#### Setup

- Move to the MDN `k8s` directory
  ```sh
  cd infra/apps/mdn/mdn-aws/k8s
  ```

- Configure your environment depending upon whether you're deploying to stage or production, and whether or not you'd like to deploy MDN in maintenance mode.

    - Stage
    ```sh
    source regions/portland/stage.sh
    ```
    - Stage in Maintenance Mode
    ```sh
    source regions/portland/stage.mm.sh
    ```
    - Production
    ```sh
    source regions/portland/prod.sh
    ```
    - Production in Maintenance Mode
    ```sh
    source regions/portland/prod.mm.sh
    ```

#### Deploying MDN with Kuma updates only

- Specify the Kuma image tag you want to deploy. It must be available from quay.io (see https://quay.io/repository/mozmar/kuma?tab=tags for a list of available tags). New Kuma images are built and registered on quay.io after every commit to the `master` branch of https://github.com/mozilla/kuma.
```sh
export KUMA_IMAGE_TAG=<tag-from-quay.io>
```

- Run the database migrations
```sh
make k8s-db-migration-job
```

- Rollout the update
```sh
make k8s-kuma-deployments
```

- Monitor the status of the rollout until it completes
```sh
make k8s-kuma-rollout-status
```

- In an emergency, if the rollout is causing failures, you can roll-back to the previous state.
```sh
make k8s-kuma-rollback
```

#### Deploying MDN with Kumascript updates only

- Specify the Kumascript image tag you want to deploy. It must be available from quay.io (see https://quay.io/repository/mozmar/kumascript?tab=tags for a list of available tags). New Kumascript images are built and registered on quay.io after every commit to the `master` branch of https://github.com/mdn/kumascript.
```sh
export KUMASCRIPT_IMAGE_TAG=<tag-from-quay.io>
```

- Rollout the update
```sh
make k8s-kumascript-deployments
```

- Monitor the status of the rollout until it completes
```sh
make k8s-kumascript-rollout-status
```

- In an emergency, if the rollout is causing failures, you can roll-back to the previous state.
```sh
make k8s-kumascript-rollback
```

#### Deploying MDN with both Kuma and Kumascript updates

- Specify the Kuma and Kumascript image tags you want to deploy.
```sh
export KUMA_IMAGE_TAG=<tag-from-quay.io>
export KUMASCRIPT_IMAGE_TAG=<tag-from-quay.io>
```

- Run the database migrations
```sh
make k8s-db-migration-job
```

- Rollout the updates
```sh
make k8s-deployments
```

- Monitor the status of the rollout until it completes
```sh
make k8s-rollout-status
```

- In an emergency, if the rollout is causing failures, you can roll-back to the previous state.
```sh
make k8s-rollback
```

## Creating MDN from scratch

This section needs to be fleshed-out. It lists the one-time steps required before performing the deployment steps described above.

#### Provision AWS and Cloud Resources
- Create an AWS RDS MySQL instance
- Create an AWS EFS volume
- Create an AWS SSL certificate
- Create an AWS ElasticCache Redis instance
- Create an AWS ElasticCache Memcached instance
- Create an ElasticCloud (Elasticsearch) instance

#### Make the K8s namespace, volumes, and services

This step is only done once, and requires special privileges for creating and configuring the AWS ELB's that will be created as part of the `make k8s-services` command.

```sh
make k8s-ns
make k8s-shared-storage
make k8s-services
```
