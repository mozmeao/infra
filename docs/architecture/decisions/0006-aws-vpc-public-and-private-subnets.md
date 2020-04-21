# 6. AWS VPC Public and Private subnets

Date: 2020-04-20

## Status

Accepted

Amends [5. VPC and Network Design](0005-vpc-and-network-design.md)

## Context

Mozilla IT SREs have built a VPC module at https://github.com/mozilla-it/itsre-deploy/tree/master/modules/vpc. This module does almost everything described in our previous ADR (#5), with one exception around public/private subnets. That difference will be described in this document.

## Decision

We will create two subnets per az. One 'public' and one 'private'. In general this is mostly by convention, rather than something that is strictly enforced.  We may later validate instances in private are not accessible to the general public with automated auditing solution. But, for now, we'll just do our best to only assign public things to the public subnet, and everything else can go in private.

The one functional item for the subnets, 'public ips' will be assigned by default in the public subnets, but not the private subnets.

## Consequences

We will provision twice as many subnets today.
For example, in us-east-1 (VA) our VPC is 10.154.32.0/20. public will be 10.154.32.0/24, 10.154.33.0/24, 10.154.34.0/24 while private will bePrivate subnets will be 10.154.35.0/24, 10.154.36.0/24, 10.154.37.0/24. 


We will be able to support fewer unique AZs per region. (Because we are creating two subnets per az instead of one).

New AZs will be added 'out of sequence'. Since our public/private have been created with no space between them, new azs be added onto the end, instead of interwoven with existing cidr blocks.
