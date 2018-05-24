# MDN Web Docs infrastructure

This repo is maintained by the [MDN Web Docs][mdn] operations team, which
includes MDN developers, Mozilla IT, and
[Mozilla Marketing Engineering and Operations][mozmeao] (MozMEAO) site
reliability engineers (SREs).

It was originally established and maintained by MozMEAO during the AWS update
in 2017-2018. In 2018, MDN engineering moved to Emerging Technologies, and this
repo was forked from [mozmeao/infra][mozmeao-infra] to the [MDN org][mdn-org].


[mdn]: https://developer.mozilla.org
[mdn-org]: https://github.com/mdn
[mozmeao]: https://mozilla.github.io/meao/
[mozmeao-infra]: https://github.com/mozmeao/infra

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
- [Python](https://www.python.org/)
  - including [boto](https://github.com/boto/boto)
- [jq](https://stedolan.github.io/jq/)
  - json transformations and queries

### Container technologies:

- [Kubernetes](https://kubernetes.io/)
  - container orchestration in the cloud
  - See [this](https://github.com/mdn/infra/tree/master/k8s) page for more info.
- [Kops](https://github.com/kubernetes/kops)
  - Kubernetes installation in AWS
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

Our goal is to use the same principle as open source development for
infrastructure management. We try to keep the planning, discussions, code,
documentation, and processes open to the community. Operational access is
limited to staff, but working in the open allows more staff members to take on
tasks, and helps new staff get up to speed quickly.

Some data, such as API keys, are sensitive. These items are stored elsewhere
and applied in production. Sensitive issues are discussed in confidential
[Bugzilla][bugzilla] issues.

The MDN team uses 3-week sprints to break up work into manageable milestones.
The MDN team work is tracked in GitHub issues and milestones using
[ZenHub][zenhub]. See the [sprints wiki][sprints] for more information.

The Mozilla IT team is tracking their tasks for the MDN project at
https://github.com/orgs/nubisproject/projects/4.

[zenhub]: https://www.zenhub.com/
[sprints]: https://github.com/mdn/sprints/wiki
[bugzilla]: https://bugzilla.mozilla.org/

## Contributing

If you'd like to make a contribution, or you've found an issue with our work,
please submit an issue and/or pull request. We're happy to take a look,
however, a timeframe for review cannot be guaranteed.

## Contacting us

We're in the `#mdndev` channel on [IRC][irc].

[irc]: https://wiki.mozilla.org/IRC
