# 3. Use Voyager for Service Ingress

Date: 2020-02-19

## Status

Accepted

## Context

We need to have load balancers between our CDNs and our services, in order to deal with k8s node failures (and for handing traffic, and as a place to log stuff, and as a way to block bad actors if needed).  We'd prefer to only pay AWS/GCP for a single load balancer thing, while still having the ability to generate unique dns addresses for each of our services.  They must be able to host certs correctly.

## Decision

We're currently managing our ELBs in aws with some out of band terraform that connects the nodes of each k8s cluster to a load balancer. Since this is out of band, upgrading clusters or services implies doing a bunch of k8s stuff, and then also running terraform.  We could possibly simplify the whole experience by moving the full definition of the load balancer, and dns, and certs to objects inside k8s.  Voyager + External Ingress seem like the most common way to do this.  Deploying one 'ingress' object per group of services you want to have behind an ALB, and listing all the DNS to point at those services solves the problem outlined above.

The primary advantage of doing this work, is that it allows dynamic things (deployments created in response to events, such as pull requests and ephemeral 'demo' branches) to be created simply by writing the yaml and deploying it to kubernetes.

## Diagram

```
                                                     K8s objects              
 Route53 entries                                                              
                          AWS Alb/k8s ingress        +-------------------+    
 +-------------------+    (created by this           |demo1 namespace    |    
 |demo1.example.com  |    project's yml)             |                   |    
 |                   |                               |test:80 k8s service|    
 +-------------------|   +-------------------+       --------------------+    
                     +---- k8s namespace:    --------+                        
 +-------------------+---- demo-shared-test  --------+                        
 |demo2.example.com  -   +-------------------+       --------------------+    
 |                   |                               |demo2 namespace    |    
 +-------------------+                               |test:80 k8s service|    
                                                     +-------------------+
```

## Consequences

We're making k8s more complex.  Managing the voyager and external dns services, and their custom resources increases the level of expertiese to run our k8s deployments.
But, we humans are no longer the glue that ties two different things (stuff inside kubernetes, and terraform created things) together.  It simplifies pipelines greatly, having to just deploy one more k8s thing instead of two different types of deployments.
