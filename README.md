# MozMEAO infrastructure

This repo is maintained by the [Mozilla Marketing Engineering and Operations](https://mozilla.github.io/meao/) (MozMEAO) site reliability engineers.

## Tools we use

### Automation and infrastructure tools:

- [Docker](https://www.docker.com/)
	- software containerization
- [Amazon Web Services](https://aws.amazon.com/)
	- our primary cloud services platform
- [Jenkins](https://jenkins.io/)
	- including [Groovy](http://www.groovy-lang.org/) scripting
- [Terraform](https://www.terraform.io/)
	- declarative infrastructure provisioning
- [Ansible](https://www.ansible.com/)
	- config automation
- [Python](https://www.python.org/)
	- including [boto](https://github.com/boto/boto)
- [jq](https://stedolan.github.io/jq/)
	- json transformations and queries

### Container technologies:

- [Kubernetes](https://kubernetes.io/)
	- container orchestration in the cloud
	- See [this](https://github.com/mozmar/infra/tree/master/k8s) page for more info.
- [Kops](https://github.com/kubernetes/kops)
	- Kubernetes installation in AWS
- [Deis 1 and Deis Workflow](https://deis.com/)
	- Deis helps developers and operators build, deploy, manage, and scale their applications on top of Kubernetes.
- [Quay.io](https://quay.io/repository/)
	- builds, analyzes, and distributed container images
	- [just how do you pronounce quay anyways?](https://www.youtube.com/watch?v=6LRYrGJg-PM)

### Monitoring tools:

- [Mig](http://mig.mozilla.org/)
	- Mozilla's real-time digital forensics and investigation platform.
- [Datadog](https://www.datadoghq.com/)
	- performance monitoring
- [New Relic](https://newrelic.com/)
	- performance monitoring
- [Papertrail](https://papertrailapp.com/)
	- centralized logging
- [FluentD](http://www.fluentd.org/)
	- collecting logs from Kubernetes pods


## How we manage our work

Our team manages it's work via a simple [Github project](https://github.com/mozmar/infra/projects/2). All data in the project is "standalone": we try to keep all links and references as public as possible, but there are obviously tasks that include sensitive data. These sensitive tasks are managed internally, and also tracked in private [Bugzilla](https://bugzilla.mozilla.org/) issues.

## Contributing

If you'd like to make a contribution, or you've found an issue with our work, please submit an issue and/or pull request. We're happy to take a look, however, a timeframe for review cannot be guaranteed.

## Contacting us

We're in the `#ee-infra` channel on IRC. More info [here](https://wiki.mozilla.org/IRC).
