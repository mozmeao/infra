# MozMEAO incident response guide

Stay cool, take a deep breath. We'll solve this problem together, and this guide is here to help.

This document does not describe the on-call or escalation process, but rather the process we use once an issue has been identified.

## Declaring an incident and the incident leader (IL) role

The incident leader (IL) serves as the primary point of contact and coordinator for an incident. This person may have been called by the moc, or just noticed that a service is broken. 

When an incident occurs, the IL posts messages in IRC stating:

- an incident has been declared and a few words about the incident
- "I am the incident leader"
- the main IRC channel for communication
    - we'll call this the *incident comms channel* in this document
- a Vidyo chat room if needed
- finally, decide if you need to notify the appropriate engineers that can help resolve the issue
    - TODO: link to on-call process

***Security incidents must not be discussed on IRC.***

Example incident declaration:

```
metadave>  MDN is experiencing an outage                          12:00 PM
metadave>  I am declaring an incident and am incident leader      12:00 PM
metadave>  updates will be posted in the #mdndev channel          12:00 PM
metadave>  ping jwhitlock rjohnson there is an urgent MDN outage  12:00 PM
metadave>  please meet in my Vidyo room                           12:01 PM
```
    
> it's helpful to include a short description of the incident when mentioning IRC users. For example `ping metadave` is not very useful when it appears as a notification on my phone, but `ping metadave MDN infra is on fire` lets me know that the issue is urgent without having to open my IRC app.

### Passing the baton

Incident response can be stressful, and it's ok if you need a break. In the incident comms channel, you can hand off the IL role to someone else if they agree. The new IL should acknowlege that they are now IL.

Example:

```
metadave>  I need a few minutes of downtime                        4:01 PM
metadave> jgmize has agreed to take over IL                        4:01 PM
jgmize> Confirmed, I am now IL                                     4:01 PM
```

## Communications

Notify the following IRC channels:

- `#mozmeao`
- `#meao-infra`
- `#moc`
    - the moc maintains an incident respone guide [here](https://mana.mozilla.org/wiki/display/SECURITY/Incident+Response#IncidentResponse-IncidentResponseTemplate).

Example:

```
metadave>  there is an MDN outage, we are working on #mdndev       12:05 PM
metadave>  I'll post an update here in the next 30 minutes         12:05 PM
```

- Notify team lead for the product impacted.

### Frequency of updates

For outages, status should be posted every 30 minutes *or less* in the incident channel.

## Incident timeline

To help write an incident report, it's very useful to include a `TL:` prefix on IRC messages when logging important events and decisions.

Example:

```
metadave> TL: listeners appear to missing from the MDN ELB          3:11 PM
            ...
            ...
metadave> TL: listeners have been manually added back to the ELB    4:05 PM
metadave> TL: listeners have been overwritten by K8s                4:10 PM
```


## Incident resolution

When an incident has been resolved, post a message in the incident comms channel stating so:

```
metadave> TL: the MDN outage has been resolved                      5:00 PM
metadave> we'll followup with an incident report                    5:00 PM
```

## Incident report

Please add an [incident report](https://mana.mozilla.org/wiki/pages/viewpage.action?pageId=52265112) to Mana within 48 hours of the incident.

## Incident response tips

- Take a few deep breaths, you're doing great!
- Stay positive, the IL is relying on teamwork to get things working again.
    - Give props to team members who are "fighting the good fight".
- Bring some humor to help break the tension.
- Don't distract the team by being critical, such as "this is poorly designed, it should be implemented with XYZ". This doesn't help us resolve the issue we're working on *right now*, but may be helpful as part of a postmortem.

