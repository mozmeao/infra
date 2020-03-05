# 2. Use Helm for Service Deployment definitions

Date: 2020-02-19

## Status

Accepted

## Context

One of the primary problems encountered in deployments is drift between different environments.  An important element that creates drift is deltas between the deployment of different environments.  We are already mitigating that by storing our configurations as code, and doing automated deployments of those configurations.  An extension of these practices is to practice code reuse, or DRY (don't repeat yourself).

Given that we have existing kubernetes deployments, and that our primary supported services (bedrock/www, snippets, basket) are already deployed there, it seems reasonable to invest further in the kubernetes eco-system.  Our current pattern is to define a separate set of yml files which are deployed via `kubectl apply -f` per region/cloud. For example, if we have gcp iowa-a and an aws frankfurt cluster, if we wish to deploy to both we'd have two copies of nearly identical files to define the deployments to those two clusters.

## Decision

Use helm3 in order to define the 'template' of our services.  Helm calls these templates 'charts', templates can have injected 'values'. The deployment, and associated kubernetes objects (such as services, and scaling policies) should be defined once, with sensible defaults chosen for the primary chart (these should be the 'prod' values).  Secrets should be referenced, but not included in the charts (paths to secrets, not the secrets themselves). Then environments that need different values should have an override file in their repo, which can be combined with defaults at deploy time. 

There should be a single mozmeao helm repo, that contains all of our custom written charts. We would expect there to be a single chart per service, where bedrock/www is a service.  There should be a pipeline for that helm repo (that includes testing).  The pipeline for each service would then reference and deploy those charts for the dev/staging/prod versions of the service.

One advantage of undertaking this work is making it easier to read and understand our deployments.  Answering 'what's different between dev and prod' is difficult when the full configuration is repeated.  It's much easier to answer when dev is defaults + a small override file, and prod is the same.  We should also end up with fewer differences, since each difference is clearly visible in the charts, and we can seek to reduce that count.

The other primary advantage is reducing the class of errors where some new feature worked in dev, but doesn't in prod because you forgot to do X. Where X is likely adding an environment variable, or creating a secret.  Having a template means we should be able to fail the deployment earlier in each environment if that configuration is not present.

## Consequences

The primary cost is to backend developers/SREs who must develop these charts. That time investment has a uncertain payoff, where the benefit is fewer configuration errors (which may not be very common today).
If we aren't careful with promoting helm charts sensibly in the service pipelines, we could accidentally grab a new version of a helm chart out of order.  Mitigation: Version helm charts.  At the point of publish assign a new value to each change. And, in the service pipeline record/promote which version of the helm chart was deployed. (This could use a 'lock' pattern, that software apps often use.)
The helm repo has to be available to deploy our services.  Mitigation: Github pages is pretty reliable, and we could also setup a 'local' repo from any up to date git repo to do emergency deploys. s3 as backup or primary chart source is also possible.
Writing the helm charts will be difficult because you need to take into account the current deltas between the existing k8s deployments.  Minimizing these deltas is one of the goals of this work. But during the transition we could deploy the services with good zero downtime patterns, where we make it easy to rollback a bad deployment.  And make sure we deploy to dev/stg/prod in order. 

