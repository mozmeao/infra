# SUMO K8s

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

## Deploying SUMO

#### Setup

- Move to the SUMO `k8s` directory
  ```sh
  cd infra/apps/sumo/k8s
  ```

- Configure your environment depending upon whether you're deploying to stage or production, and whether or not you'd like to deploy MDN in maintenance mode.

    - Dev
    ```sh
    source regions/oregon-b/dev.sh
    ```

#### Deploying SUMO

- Specify the SUMO image tag you want to deploy. 

```sh
export SUMO_IMAGE_TAG=<tag-from-quay.io>
```

- Run the database migrations

```sh
#TODO: does not exist yet!
#make k8s-db-migration-job
```

- Rollout the update
```sh
make k8s-web
```

- Monitor the status of the rollout until it completes
```sh
make k8s-sumo-rollout-status
```

- In an emergency, if the rollout is causing failures, you can roll-back to the previous state.
```sh
make k8s-sumo-rollback
```



