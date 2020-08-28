# How we work in 2020

Our team manages it's work via Github [projects](https://github.com/orgs/mozmeao/projects/2). 

The goals of this process are:

1. Have a single, easily accessable source of truth of what the team is working on.
2. Allow the team to prioritize and organize work.
3. Organize team-wide projects ("swarming") to foster collaboration, prevent isolation, spread knowledge, and bring ⚡️energy⚡️ to cloud engineering

All data in the project is "standalone": we try to keep all links and references as public as possible, but there are sometimes tasks that include sensitive data. Confidential or sensitive tasks should be managed in private Bugzilla issues and linked to from the board.

## Work Cadence

We will work in 2 week sprints that start and end on Wednesdays. 


## Organizing Work

Our work will generally be organized into Epics & Issues. 

### Epics

Epics are bodies of work that are made up of multiple issues. Generally if a body of work requires more than one task, it should be part of an epic (e.g. Automatically generate a Mozilla.org Sitemap = probably a good epic).

### Issues

Issues are a breakdown of the work that needs to get done. Exactly how much work makes up an issue is a bit of a moving target but a good general guideline is try to make it atomic, the type of thing that would involve a single PR.

### The Project Board

Epics and issues live on [our task board](https://github.com/orgs/mozmeao/projects/2) located in the MozMEAO Github organization. Note that projects at this level are not specific to any one repo. A project at the organization level allows us to easily link and track issues and PRs from `mozmeao` repos. 

## Board Usage

### Creating An Epic

Github does not natively handle epics, so we are using labels to create epic like grouping. The label allows you to filter a board and just see the issues associated with an epic.


### Epic Labels

Epic lables should:
- Always be the same color (#0000FF)
- Follow the format EPIC: _Unique Name_
- Be named so they are unique
- Should be deleted once the work is complete




## Adding Issues To The Task Board

### Issues and PR's in `mozmeao` repos <a name="addingissues"></a>

From the [project UI](https://github.com/orgs/mozmeao/projects/2), click the `Add cards` link and drag the card to the appropriate column.

### Issues and PR's in external repos

Click the `+` sign in any column of the project and add a brief description *AND links to one or more external issues that you'd like to track*, then click the `Add` button. 

> Adding multiple links in the body of a note will enable a 'Show' button that can be expanded to show additional detail for each linked issue.

### Issue Labels

Issues should be labeled during our weekly review meeting. It is not required that we wait until a meeting to label incoming issues.

As a general rule, try to use existing labels. However, if none of the existing labels work for you and the label will most likely be used more than once, go ahead and create a new one.


### Tracking Bugzilla issues

When tickets are created in Bugzilla, they can be tracked in our [MozMEAO backend/infra](https://github.com/orgs/mozmeao/projects/2) project. This is not required, but can be helpful for bookkeeping on our end, including the need to perform followup tasks when a bug is closed.

The issue should contain a link to the Bugzilla bug and any relevant labels and assignees. It can also serve as a place for team discussion related to the Bugzilla ticket without cluttering the original request. These cards can be moved directly to the `In Progress` column of the [MozMEAO backend/infra](https://github.com/orgs/mozmeao/projects/2).

### High priority issues

Urgent/high priority issues should be marked with the `high priority` label and moved to the top of the `In Progress` (or `Queued`) column. Engineers's should communicate the status of high priority issues at _least_ once a day, and note any updated status on the issue.


##### Examples:

- non-critical security updates to any of our managed servers
    - critical security updates should be labeled as `high priority`.
- troubleshooting / updating Jenkins
- submitting tickets to webops in response to developer needs
- and more!


## Task board column definitions

### Prioritized Backlog

All the work that we intend to do at some point with the highest priority issues at the top.

### Current Sprint

Work that we have commited to completing during the current sprint, again ordered by priority.

### In Progress

Tasks that are actively being worked on. We should not have more than our WIP number of cards in this column. See the WIP section for more info.

### Review

Tasks that are waiting for QA, PR review, discussion, and/or merging. 

### Done

The work is _live_ and no additional work is required. 

### Task Board Work-in-Progress Limits

Each engineer should have between 1-3 issues that they are working on, which we'll call the `WIP limit`. In progress` column should include `(limit 12)`, or whatever limit we decide is appropriate.


### Every Two Week Sprint Planning

We have an every two week sprint planning meeting. The goal of this meeting is to commit to a body of work for the next sprint.

For this meeting to be efficent we should always keep the prioritized backlog accurate and pritoritized :)


