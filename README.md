# MozMEAO infrastructure

This repo is maintained by the [Mozilla Marketing Engineering and Operations](https://mozilla.github.io/meao/) (MozMEAO) site reliability engineers.

## Tools we use

### Automation and infrastructure tools:

- [Docker](https://www.docker.com/)
	- software containerization
- [Amazon Web Services](https://aws.amazon.com/)
	- our primary cloud services platform
- [Google Cloud Platform](https://cloud.google.com/)
- [Gitlab CI/CD](https://gitlab.com) and [Jenkins](https://jenkins.io/)
- [Terraform](https://www.terraform.io/)
	- declarative infrastructure provisioning
- [Ansible](https://www.ansible.com/)
	- config automation
- [Python](https://www.python.org/)
	- including [boto](https://github.com/boto/boto)
- [jq](https://stedolan.github.io/jq/)
	- json transformations and queries

### Monitoring tools:

- [New Relic](https://newrelic.com/)
	- performance monitoring
- [Papertrail](https://papertrailapp.com/)
	- centralized logging
- [FluentD](http://www.fluentd.org/)
	- collecting logs from Kubernetes pods


## How we do CI/CD

See the [MozMEAO CI/CD Architecture doc](https://docs.google.com/document/d/1do_jZPA50rLraLzNXuAgRObj0kxc5H36xWk0KIzE1fg/edit?usp=sharing) (limited to Mozillians).

## How we manage our work

See [how we work](docs/how_we_work.md) doc.

## Contributing

If you'd like to make a contribution, or you've found an issue with our work, please submit an issue and/or pull request. We're happy to take a look, however, a timeframe for review cannot be guaranteed.
