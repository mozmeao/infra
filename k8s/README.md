# MozMEAO Kubernetes


This directory contains Kubernetes installation automation.

0. [Spin up a micro instance in AWS EC2](https://github.com/mozmeao/infra/tree/master/k8s/dev_node) to get started. Once you have a node running in EC2, delete your local AWS creds. We'll use the AWS metadata service to provide our creds during install.

0. Then, [install Kubernetes](https://github.com/mozmeao/infra/tree/master/k8s/install) and associated MozMEAO services.
