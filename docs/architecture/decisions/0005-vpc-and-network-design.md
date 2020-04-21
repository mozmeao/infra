# 5. VPC and Network Design

Date: 2020-04-07

## Status

Accepted

Amended by [6. AWS VPC Public and Private subnets](0006-aws-vpc-public-and-private-subnets.md)

## Context

Changing networking can be hard.  It usually requires a full redeploy of all services and all infrastructure to make it 'real'.  Our current network has overlaps, which makes it more difficult to setup vpns, usually requring syncing of live IP addresses to their desired state.

## Decision

Netops will reserve a /16 block of ips for mozmeao. For each VPC make a block of /20 ipv4 addresses.  Where VPC maps to a region within a cloud provider we use.  Divide that into /24 subnets, where we'll have just one subnet per AZ. 

Our /16 is - 10.154.0.0/16

For example, in oregon, the network would look like:

| Label           | CIDR          | Range Start  | Range End      | Description                     |
|-----------------|---------------|--------------|----------------|---------------------------------|
| Oregon VPC      | 10.154.0.0/20 | 10.154.0.1   | 10.154.15.254  | A large block for the whole VPC |
| Oregon Subnet A | 10.154.0.0/24 | 10.154.0.1   | 10.154.0.254   | Subnet for oregon-a az          |
| Oregon Subnet B | 10.154.1.0/24 | 10.154.1.1   | 10.154.1.254   | Subnet for oregon-b az          |
| Oregon Subnet C | 10.154.2.0/24 | 10.154.2.1   | 10.154.3.254   | Subnet for oregon-c az          |

and Frankfurt would be:

| Label              | CIDR           | Range Start   | Range End       | Description                        |
|--------------------|----------------|---------------|-----------------|------------------------------------|
| Frankfurt VPC      | 10.154.16.0/20 | 10.154.31.1   | 10.154.255.254  | A large block for the whole VPC    |
| Frankfurt Subnet A | 10.154.16.0/24 | 10.154.16.1   | 10.154.16.254   | Subnet for frankfurt-a az          |
| Frankfurt Subnet B | 10.154.17.0/24 | 10.154.17.1   | 10.154.17.254   | Subnet for frankfurt-b az          |
| Frankfurt Subnet C | 10.154.18.0/24 | 10.154.18.1   | 10.154.18.254   | Subnet for frankfurt-c az          |

The next few vpc blocks would be 10.154.32.0/20, 19.154.48.0/20, 19.154.128.0/20

In oregon we could continue with 10.154.3 and 10.154.4 until 15 for the subnets.  Essentially the same for frankfurt 10.154.19, 10.154.20.

## Consequences

Routing from the vpn becomes much simpler.  Since there is no overlap, we map all the vpc cidrs in the vpn, and then any dns a user hits with a 10.154.x.x ip is directed straight to aws.

We will have to redeploy all of our infrastructure to use the new networking space.

If we want another /16 address, we should request it from netops.  But, we fully own this /16, and no-one at at mozilla should deploy into that space.

Using /20 means we have 16 chunks for unique VPCs.  Then from /20 to /24 we have another 16 chunks inside of that. If we create more vpcs or more subnets than that, we'll have quite a few issues getting everything working.  It seems unlikely we'll need more than 16 vpcs or more than 16 subnets inside that vpc, which is how we decided on these numbers.

## Active Documentation

Active network definitions will be stored in these two documents:

https://github.com/mozmeao/infra-services/blob/master/aws/README.md
https://github.com/mozmeao/infra-services/blob/master/gcp/README.md
