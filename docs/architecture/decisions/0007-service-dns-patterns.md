# 7. Service dns Patterns

Date: 2021-01-04

## Status

Accepted

## Context

Our current dns naming follows a couple of very similar patterns. Sometimes using 'gcp', 'frankfurt', 'oregon-b' as ways to separate different environments.  We should have one pattern and stick to it the best we can.

Things the pattern needs to solve for:

* Should be 'the same' for all of the meao services (for example: nucleus/bedrock/snippets).
* should allow for multiple 'environments' of a service to be deployed in the same region ('prod'|'stg'|'dev')
* should allow for multiple regions/deployments of the same service + environment ('or', 'fr', 'ia')
* should also have a good 'user facing' pattern, that is not the same as the above pattern. (www.mozilla.org -> 'bedrock' 'prod' 'or' && 'bedrock' 'prod' 'fr' with some mechanism for choosing between the two deployments.)

## Decision

For the backend deployments follow this pattern: 'service'.'environment'.'region'.'domain'. An incomplete list of each of examples of values for those variables:

| Service  |
|----------|
| bedrock  |
| nucleus  |
| snippets |
| prom     |

| Environments |
|--------------|
| dev          |
| stg          |
| prod         |
| demo1        |

| Region | Description           |
|--------|-----------------------|
| or     | oregon eks cluster    |
| fr     | frankfurt eks cluster |
| ia     | iowa gcp cluster      |

| Domain     |
|------------|
| moz.works  |
| mozmar.org |
| ramzom.org |

This leads to a few examples:

| Examples                 |
|--------------------------|
| bedrock.dev.or.moz.works |
| prom.prod.fr.mozmar.org  |
| nucleus.stg.ia.moz.works |


Note that these are for 'internal' use primarily.  The user facing domains will stay as they are.  A few examples, nucleus.mozilla.org (prod) and nucleus.allizom.org (stg), www.mozilla.org (bedrock prod) www.allizom.org (bedrock stg).  The connection between the new dns entries and the user facing will stay the same. (If we're using a r53 traffic policy now, we will continue to after this change, if we're just using cname/alias records we will again after this change,etc, including cloudflare vs cloudfront etc.)



## Consequences

All services will live at new addresses.
Old addresses will need to be deleted.
