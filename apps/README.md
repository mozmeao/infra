# MozMEAO applications


### Application directory structure

Applications created as subdirectories of `./apps` should be organized in the following structure:

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
  
The purpose of this structure is to Make It Easy™ for engineers to deploy 
applications without having to search through Github issues, other repos, 
or running many commands manually. While our application installs aren't 100% 
automated _yet_, adding as many commands as possible to the scripts in an 
application directory will make it easier down the road to setup new regions 
or new instances of an application.


- `setup.sh` includes Deis Workflow provisioning and any K8s services that need to
be created. This currently consists of NodePorts (which must be created after Deis
creates the K8s app namespace). New Relic/Datadog monitoring should be setup here
as well. 

The goal here is not to have the app production-ready, but to create 
any components the app needs, leaving a few _documented_ manual steps such as
pushing a Deis config. Once this is complete, Jenkins can finish the
work of deploying the latest version of the app.
  - scripts should include `bin/common.sh`, and call `check_meao_env` to ensure
  the user has Deis and Kubernetes environment variables set.
  - it's ok for `setup.sh` to pull older/hardcoded versions of an application,
  as Jenkins will in most cases push the latest version out for us.
  - when creating Deis applications, keep in mind that a `Procfile` is needed in
  the current directory. For now, we can download a Procfile into the current 
  directory with a command such as:
    `wget https://raw.githubusercontent.com/mozilla/bedrock/master/Procfile`
- `teardown.sh` can delete the Deis app and K8s namespace (including any services
in the namespace). New Relic/Datadog monitoring should be deleted here.
- `scale.sh` should include Deis app scaling, or any HPA scaling that needs to be
completed. The reason that it's separated into it's own script is that it can
take quite some time to scale Deis apps.
- `README.md` should contain any high level information regarding the application, 
including a link to the source repo for the app.  More detailed documentation should be placed in the `./docs` directory.
- `docs/support.md` should include any links, docs and/or commands that can be run to troubleshoot an application.
- the `infra` directory contains any additional application-specific Terraform provisioning.
It's divided into two separate areas: `multi_region` and `shared`.
  - `multi-region` are resources that can be created in many regions. Examples 
  are EC2 instances, security groups, RDS instances, SQS etc.
  - `shared` are resources that are global across AWS.
  - **NOTE**:  Terraform state MUST be stored in an encrypted bucket. **NEVER**
  check Terraform state containing sensitive information into this Git repo.
  - IAM related resources should be created in our private repo.
- `./k8s` contains any Kubernetes resource yaml that should to be applied when `setup.sh`
is run. Note that `setup.sh` doesn't run this code automatically, you have to call the appropriate `kubectl` command.
- it's not required that commands be made idempotent in any of the scripts, however, it certinaly doesn't hurt if they are.
- it's not required to have all or any of these files, however, consistency can help
with managing many complex applications.

#### Creating a new app

The `create_app_skeleton.sh` script in the current directory creates a app
skeleton in a new subdirectory (named after the app/first argument passed to the
script).

```
create_app_skeleton.sh my_new_app
```

