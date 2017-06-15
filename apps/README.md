# MozMEAO applications


### Application directory structure

Below is a sample directory structure for a fictitious `testapp` application.

```
testapp/
├── docs
│   └── support.md
├── infra
│   ├── multi_region
│   │   ├── frankfurt
│   │   │   └── provision.sh
│   │   ├── tf
│   │   │   ├── common.sh
│   │   │   ├── main.tf
│   │   │   ├── output.tf
│   │   │   └── variables.tf
│   │   ├── tokyo
│   │   │   └── provision.sh
│   │   └── virginia
│   │       └── provision.sh
│   └── shared
│       ├── main.tf
│       └── provision.sh
├── k8s
│   ├── testapp_prod_nodeport.yaml
│   └── testapp_stage_nodeport.yaml
├── README.md
├── scale.sh
├── setup.sh
└── teardown.sh
```

- `setup.sh` includes Deis Workflow provisioning and any K8s services that need to
be created. This currently consists of NodePorts (which must be created after Deis
creates the K8s app namespace). New Relic/Datadog monitoring should be setup here 
as well.
  - scripts should include apps/bin/common.sh, and call `check_meao_env` to ensure
  the user has Deis and Kubernetes environment variables set.
  - it's ok for `setup.sh` to pull older/hardcoded versions of an application,
  as Jenkins will in most cases push the latest version out for us.
- `teardown.sh` can delete the Deis app and K8s namespace (including any services
in the namespace). New Relic/Datadog monitoring should be deleted here.
- `scale.sh` should include Deis app scaling, or any HPA scaling that needs to be
completed. The reason that it's separated into it's own script is that it can
take quite some time to scale Deis apps.
- `README.md` should contain any high level information regarding the application.
More detailed documentation should be placed in the `./docs` directory.
- `docs\support.md` includes any commands that can be helpful to troubleshoot
the application.
- the `infra` directory contains any additional application-specific provisioning.
It's divided into two separate areas: `multi_region` and `shared`. 
  - `multi-region` are resources that will be created per-region.
  - `shared` are resources that are global across AWS.
  - **NOTE*:*  Terraform state MUST be stored in an encrypted bucket. **NEVER**
  check Terraform state containing sensitive information into this Git repo.
  - IAM related resources should be created in our private repo.
- `./k8s` contains any Kubernetes resource yaml that needs to be applied when `setup.sh`
is run.
