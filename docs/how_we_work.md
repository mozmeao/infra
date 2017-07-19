# SRE Project Management

Our team manages it's work via a simple [Github project](https://github.com/mozmeao/infra/projects/2). All data in the project is "standalone": we try to keep all links and references as public as possible, but there are obviously tasks that include sensitive data. These sensitive tasks are managed internally, and also tracked in private Bugzilla issues.

For non-SRE's that perform infrastructure-related tasks, we have the [Backend SRE-related tasks](https://github.com/mozmeao/infra/projects/3) project board.

## Milestones

At a high level, we have `Q1`, `Q2`, `Q3`, and `Q4` milestones to group work into. Projects that include many tasks that can live for greater than a few weeks should use a custom milestone.

Milestones should be created with agreement between SRE's and SRE management. Any non-specific work should fall into one of the `Q1`-`Q4` milestones.

### Infrastructure transition projects

When working on larger infrastructure transition projects that have many moving pieces, it's best to create a new Milestone to track this work. Each issue should be assigned this milestone and appropriate labels to track progress.

We've had some issues using Github issue checkboxes between multiple engineers, so let's stick with milestones.

We also have the ability to create ephemeral Github projects for larger transition projects, however, this may make it harder to track overall SRE work status.

## Creating infrastructure issues

Infrastructure issues can be submmitted via [this page](https://github.com/mozmeao/infra/issues). Please include a brief description and any related links that may be useful. All issues submitted to the [infra](https://github.com/mozmeao/infra/) repo should be tagged and prioritized within a few business days.

See the `Prioritizing Issues` section for info on high priority issues.

### Card content

***Please do NOT add ANY secure or sensitive text to an issue or pull request in this repo.***

Some of our cards have simple descriptions, such as "Upgrade Virginia cluster to Kubernetes v1.6.0". While a description like this is generally OK, you are encouraged to add as much prose and links as you see fit.

Remember, the author of an issue may not be the engineer who works on the card, so any relevant information that can be helpful should be included.

### Cards vs issues

If creating cards via the Github Project interface, please convert the card to an issue as soon as possible. This allows us to use the Github Issues interface to filter by author, labels, project, milestone and assignee. We occasionally create reminder cards with the intent of converting it to a full issue in the near future.

### Issue Labels

Issues should be labeled by an SRE upon triage. While we have a weekly triage meeting (see the `Prioritizing Issues` section below), it is not required that we wait until this meeting to label incoming work.

As a general rule, try not to create new labels. However, if none of the existing labels work for you and the label will most likely be used more than once, go ahead and create a new one.

### Assignments

If you're an SRE, you can assign an issue to another engineer on the team. This is **not** required when submitting an issue. As a courtesy, ping the engineer that will be assigned to the issue and let them know it's incoming.

Non-SRE's shouldn't assign issues to specific engineers, and should wait for the SRE team to prioritize and assign incoming work.

### Tracking Bugzilla issues

When tickets are created in Bugzilla, they can be tracked in our [SRE project](https://github.com/mozmeao/infra/projects/2) with a simple issue. This is not required, but can be helpful for tracking on our end, including the need to perform followup tasks when a bug is closed.

The issue should contain a link to the Bugzilla issue and any relevant labels and assignees. It can also serve as a place for team discussion related to the Bugzilla ticket without cluttering the original request. These cards can be moved directly to the `In Progress` column of the [MozMEAO SRE project](https://github.com/mozmeao/infra/projects/2).

## Prioritizing issues

We have a weekly issue triage meeting on Tuesdays at 12:30pm US eastern/9:30am US pacific. Here we open the [Github project](https://github.com/mozmeao/infra/projects/2) and work right to left to clean up the board.

Process:

- start with the top of the `Review` column, ensure that each issue is receiving appropriate review. If the issue has already been resolved/merged/closed, move to the **top** of the `Complete` column.
- Next, review each card in the `In Progress` column to ensure the issue isn't blocked. Blocked issues should be updated with an appropriate note. When an SRE has submitted a PR, the card should be moved to the **top** of the `Review` column. Pull requests are _usually_ reviewed within 1 business day, and don't need to wait until the weekly triage meeting to be moved to the `Review` column.
    - The `In Progress` column should generally not have more than 2-3 open cards per engineer.
- Next, review the `Queued` column starting from the top. The top represents the highest priority queued tasks that SRE's should work on next.
    - are there any cards in this column that have been deferred? If so, move them to the `Backlog` column.
- Next, review the `Backlog` for cards that can be moved to the `Queued` column. Keep in mind that cards at the top of the `Queued` column are highest priority.
- Review project-specific milestone progress.
- Review quarterly milestone progress, reprioritize issues that may fall off the end of a milestone.
- The `Backlog` column can get long. When there are too many columns in the backlog, we should make a best effort to move issues off of our project board into an external document (yet to be defined). If the issue should still receive attention within the next 12 months, it can remain in the `infra` repo and be marked with a prospective quarterly milestone.

### High priority issues


If an urgent issue occurs, please contact the SRE team directly on IRC, Slack, phone etc.

> For sensitive topics, please contact us using the `#meao-infra` room in the Mozilla shared slack instance.

> For non-sensitive topics, you can contact us in the `#meao-infra` room on [Mozilla's IRC server](https://wiki.mozilla.org/IRC).

Urgent/high priority issues should be marked with the `high priority` label and moved to the top of the `In Progress` (or `Queued`) column. SRE's should communicate the status of high priority issues at _least_ once a day, and note any updated status on the issue.

Critical security updates should be labeled as `high priority`.

### Non-project support issues

The SRE team frequently has to react to production and non-production events in order to see to ensure reliable service delivery. While the main `In Progress` queue is refined once a week (see the `Prioritizing Issues` section), it's ok for non-urgent support tasks to be interleaved into our weekly milestone work. This is at the discretion of the SRE team and management.

##### Examples:

- non-critical security updates to any of our managed servers
    - critical security updates should be labeled as `high priority`.
- troubleshooting / updating Jenkins
- submitting tickets to webops in response to developer needs
- and more!

## Submitting pull requests

When possible, a pull request should be linked to any associated Github issues to the `infra` repo. If the PR includes work for a specific Bugzilla ticket, the Bugzilla ticket number should be attached to the associated Github issue as well as the PR.

Tagging/milestones are not as important here, although it doesn't hurt.

### Non-Mozillian pull requests

Open source is awesome, and sometimes we get pull requests from non-Mozillians. We should strive to comment and review these PR's as quickly as possible, barring any high priority issues. It's a bummer to be an external contributor and submit a PR that's ignored. Let's try out best to encourage external contributors.

TODO: should we ever consider a [Developer Certificate of Origin](https://github.com/habitat-sh/habitat/blob/master/CONTRIBUTING.md#signing-your-commits).

### Github Project Columns Defined

##### Backlog

A list of possible tasks. Tasks in this column are not actively being worked on. In our weekly triage meeting this list is briefly discussed and if needed, prioritized. Items that will not realistically be worked in the near future should be assigned the label _icebox_.

##### Queued

Tasks that have been prioritized as what we should do next. These tasks can be thought of as _ready_ and can be started at any time.

##### In Progress

Tasks that are actively being worked on.

##### In Review

Tasks that _maybe_ complete but are pending QA, PR review, discussion, or merging (or all 4).

##### Complete

The task is complete, it is _live_ and no additional work is required.


### Workflow / How Cards Move Across The Board

Cards from the queued column are pulled from left to right by whomever has taken that task. If you take a task please ensure you add yourself to the assignee list.

We are currently not enforcing _Work In Progress_ limits for each column, however a good guideline is not to have more than 3 cards assigned to you in progress at any given time.
