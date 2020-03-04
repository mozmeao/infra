# 4. Prometheus and Alertmanager Monitoring and Alerting

Date: 2020-03-04

## Status

Accepted

## Context

We want to have a flexible, easy to run, but not too expensive alerting and monitoring solution.  Since we are primarily kubernetes based, something built around that seems ideal.  We are in a little bit of a rush given that our current monitoring solution has yearly renewals, and that renewal would be coming up at the end of the month.

Possible options include, influx cloud (v1, v2), influx we host (rejected mostly because v2 is not yet ready for primetime, and team has no influx familiarity).  New Relic, DataDog, HoneyComb are all great products, but are a bit expensive for us (saas prices for our data load seem to be too much).  Tools like Nagios are hard to run in the cloud because they assume mostly assume 100% network reliability.  Given all that, and our team's familiarity with prometheus, it seems like the best choice.

## Decision

Run prometheus and alertmanager, on our clusters.  Run one prom per k8s cluster to collect metrics. Run one prom/grafana/alertmanager deployment to collect and display the information all in one place.  Send alerts to slack and/or pagerduty depending on severity.  Monitor this stack with dead man's snitch or other negative alerting services.

## Consequences

We own the deployment, configuration and maintenance of yet another tool.  Monitoring and alerting have some complexity to them, and running a stateful service on kubernetes can be tricky.  We must be willing to pay those costs, and work through the problems as they arise for the service(s).
