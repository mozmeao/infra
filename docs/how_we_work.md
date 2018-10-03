# How we work in 2018

#### tl;dr

Our team manages it's work via two Github projects separated into [milestones](https://github.com/orgs/mozmeao/projects/3) and [tasks](https://github.com/orgs/mozmeao/projects/2). 

The goal of this process is to:

- establish and follow a team roadmap
- organize team-wide projects ("swarming") to foster collaboration, prevent isolation, spread knowledge, and bring ⚡️energy⚡️ to cloud engineering
- plan, prioritize and assign work in a fair and balanced way
- communicate status within the MozMEAO team and marketing organization
- identify risks, blockers and high priority issues

All data in the project is "standalone": we try to keep all links and references as public as possible, but there are obviously tasks that include sensitive data. These sensitive tasks are managed internally, and can also be tracked in private Bugzilla issues.


# Milestones

Milestones are higher level goals that can contain multiple tasks, and will generally be >= 2 weeks of work.  

[Our milestone board](https://github.com/orgs/mozmeao/projects/3) is a set of notes (aka cards) that link to milestones in any Github organization or repo. Note that this board doesn't contain any milestones itself (only links to milestones), and it exists because milestones don't easily track across orgs (`mozmeao` and `mozilla` in our case).

## Scheduling and cadence

Once a milestone is completed, we'll decide whether to immediately continue on to the next milestone or take a 2-3 day quality improvement break for periodic system maintence, small automation opportunities or one-off backend tasks.

# Tasks / Issues

Tasks (aka issues - as thats how they're organized in Github) are <= 4 hour units of work, give or take a few hours. Anything requiring more effort should be split into multiple tasks. 

[Our task board](https://github.com/orgs/mozmeao/projects/2) is located in the MozMEAO Github organization. Note that projects at this level are not specific to any one repo. A project at the organization level allows us to easily link and track issues and PRs from `mozmeao` repos. 


# Backlogs

Each repo will keep it's own backlog of tasks. Each project owner will periodically identify either larger tasks that can be organized into a miletone, or one-off tasks that can be directly added to our task board.

# Board Usage

## Creating a new milestone

Visit your project (any org/any repo), click `Milestones` followed by `New milestone`. 

### Adding issues/tasks to a milestone

A single issue can be assigned to a milestone by viewing the issue and assigning a milestone on the right side of the screen.

Multiple issues can be assigned to a milestone by clicking on a repo's `Issues` tab, selecting multiple issues, and then picking a value from the `Milestone` dropdown/filter.

## Linking milestones to the milestone board

Visit the [milestone board](https://github.com/orgs/mozmeao/projects/3), and click the `+` icon in the `To do` column. Add a one line description followed by a link to the Github milestone.

For example:

```
Bedrock Django 1.11 upgrade
https://github.com/mozilla/bedrock/milestone/3
```

## Adding issues to the task board

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

### Non-project support issues

The SRE team frequently has to react to events in order to ensure reliable service delivery. While the main `In Progress` queue is periodically refined, it's ok for non-urgent support tasks to be interleaved into our weekly work. This is at the discretion of the SRE team and management.

##### Examples:

- non-critical security updates to any of our managed servers
    - critical security updates should be labeled as `high priority`.
- troubleshooting / updating Jenkins
- submitting tickets to webops in response to developer needs
- and more!


## Task board column definitions

### Queued

Work that is scheduled for the next 1-2 weeks. These tasks are identified by project owners from a repo-specific backlog or milestone (bedrock, basket, infra, etc). Tasks in this column can be thought of as _ready_ and can be started at any time.

### In Progress

Tasks that are actively being worked on. This can include (but is not limited to) analysis, development and/or troubleshooting. We should not have more than our WIP number of cards in this column. See the WIP section for more info.

### Review

Tasks that are waiting for QA, PR review, discussion, and/or merging. Once a card is in this column, you can pull a new card off the Queued column.

### Complete

The task is complete, it is _live_ and no additional work is required. 

## Task board work-in-progress limits

Each engineer should have between 1-3 issues that they are working on, which we'll call the `WIP limit`. For a team of 4 backend engineers/SRE's, let's start with 4 * 3. While this limit is not strictly enforced, exceeding it will cause more context switching and possibly slow down other work.

The title of for the `In progress` column should include `(limit 12)`, or whatever limit we decide is appropriate.


## Milestone board column definitions

### To do

This column holds milestones that will be started when the milestone(s) in `In Progress` has been completed.

### In Progress

Milestones in progress, with an initial WIP of 2. 

### Done

Milestones with all associated tasks/issues completed are moved to the `Done` column.

### Milestone board work-in-progress limits

We'll start with a preference for 1 milestone in progress at any one time, with a max of 2. 

# Meetings

### Bi-weekly milestone review

[Milestone board](https://github.com/orgs/mozmeao/projects/3)

We have a bi-weekly milestone review meeting on Thursdays at 7:30am Pacific. The goal of this meeting is to review and plan milestones, and identify blockers or at-risk miletones. 

#### Process

- Start with the top of the `In Progress` column, ensure that progress is being made for each milestone. 
- Add new milestones to the `To do` column.

### Weekly task review

[Task/Issue board](https://github.com/orgs/mozmeao/projects/3)

We have a weekly task/issue review meeting on Tuesdays at 7:30am Pacific. The goal of this meeting is to review our task board, replenish the `Queued` column of the board with new work, and to identify blockers or at-risk tasks.

#### Process:

- Start with the top of the `Review` column, ensure that each issue is receiving appropriate review. If the issue has already been resolved/merged/closed, move to the **top** of the `Complete` column.
- Next, review each card in the `In Progress` column to ensure the issue isn't blocked. Blocked issues should be updated with an appropriate note. When an engineer has submitted a PR, the card should be moved to the **top** of the `Review` column. Pull requests are _usually_ reviewed within 1 business day, and don't need to wait until the weekly triage meeting to be moved to the `Review` column.
    - Let's make sure the `In Progress` column is obeying the WIP limit.
- Next, review the `Queued` column starting from the top. The top represents the highest priority queued tasks that engineers should work on next.
    - are there any cards in this column that have been deferred? If so, do they still belong on this task board?
    - move cards from `Queued` to `In Progress`, and assign one or more engineers to work on the issue.
- Project owners will add cards to this column for their respective projects. We should strive to keep ~2 weeks of work in the `Queued` column.


# Example

We'd like to upgrade Django to 1.11 for Kitsune. 

[A milestone has been created](https://github.com/mozilla/kitsune/milestone/5) in the Kitsune repo to track individual upgrade tasks. These tasks can be arbitrarily ordered by dragging the left side of each task row. Three tasks have been added to the milestone, and there may be a few more resulting from [this audit](https://github.com/mozilla/kitsune/issues/3304). 

A [progress bar for this milestone](https://github.com/mozilla/kitsune/milestones) is visible by clicking `Issues`, followed by `Milestones` from the [root of the repo](https://github.com/mozilla/kitsune).

To track this milestone along with all other team milestones, we use [this board](https://github.com/orgs/mozmeao/projects/3).  This allows us to link to a _milestone_ from any org/repo in Github. 

We then track any work from a milestone the same way we've been tracking cross-org/repo issues on our [task board](https://github.com/orgs/mozmeao/projects/2?card_filter_query=repo%3Amozilla%2Fkitsune) (link has a filter for `mozilla/kitsune` issues, and issues may no longer appear on the board depending on when you're reading this).