# 5. VPC and Network Design

Date: 2020-04-07

## Status

Accepted

## Context

Changing networking can be hard.  It usually requires a full redeploy of all services and all infrastructure to make it 'real'.  Our current network has overlaps, which makes it more difficult to setup vpns, usually requring syncing of live IP addresses to their desired state.

This document is referenced for design, in particular the sizing section which says, "The majority of AWS customers use VPCs with a /16 netmask and subnets with /24 netmasks". https://aws.amazon.com/answers/networking/aws-single-vpc-design/

## Decision

For each VPC make a block of /16 ipv4 addresses.  Where VPC maps to a region within a cloud provider.  Divide that into /24 subnets, where we'll have just one subnet per AZ. 

For example, in oregon, the network would look like:

| Label           | CIDR         | Range Start | Range End     | Description                     |
|-----------------|--------------|-------------|---------------|---------------------------------|
| Oregon VPC      | 10.10.0.0/16 | 10.10.0.1   | 10.10.255.254 | A large block for the whole VPC |
| Oregon Subnet A | 10.10.0.0/24 | 10.10.0.1   | 10.10.0.254   | Subnet for oregon-a az          |
| Oregon Subnet B | 10.10.1.0/24 | 10.10.1.1   | 10.10.1.254   | Subnet for oregon-b az          |
| Oregon Subnet C | 10.10.2.0/24 | 10.10.2.1   | 10.10.3.254   | Subnet for oregon-c az          |

and Frankfurt would be:

| Label              | CIDR         | Range Start | Range End     | Description                        |
|--------------------|--------------|-------------|---------------|------------------------------------|
| Frankfurt VPC      | 10.11.0.0/16 | 10.11.0.1   | 10.11.255.254 | A large block for the whole VPC    |
| Frankfurt Subnet A | 10.11.0.0/24 | 10.11.0.1   | 10.11.0.254   | Subnet for frankfurt-a az          |
| Frankfurt Subnet B | 10.11.1.0/24 | 10.11.1.1   | 10.11.1.254   | Subnet for frankfurt-b az          |
| Frankfurt Subnet C | 10.11.2.0/24 | 10.11.2.1   | 10.11.3.254   | Subnet for frankfurt-c az          |

## Consequences

Routing from the vpn becomes much simpler.  Since there is no overlap, we map all the vpc cidrs in the vpn, and then any dns a user hits with a 10.x.x.x ip is directed straight to aws.

We will have to redeploy all of our infrastructure to use the new networking space.

We should be safe to make new subnets in a vpc, or to build out new vpcs as needed, without overlap.  There's a limit on the number of both, an using /16 addresses limits the number of vpcs we can support.  MozMEAO don't have very many regions/vpcs (and no likely reason for that count to grow quickly), so it seems safe to assume there will be enough blocks for now.  
