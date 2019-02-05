# Setup GitLab as CI/CD For Your Project

We have a [GitLab Runner][] configured for all projects in our [GitLab Group][].
Follow these instructions to setup your Github project to use this for your Continuous Integration (CI) and Continuous Deployment (CD) needs. We'll basically be following along with [GitLab's docs for manually setting this up][gitlab-manual].

## Create a GitLab Project

* Login to GitLab and navigate to our [GitLab Group][].
* Click the "New Project" button.
* Select the "CI/CD for external repo" tab at the top.
* Select "Repo by URL" so that we can manually connect everything and avoid extra permissions.
* Enter the URL for your repo (e.g. https://github.com/mozilla/bedrock.git) (no auth is required if the repo is public).
* Give it a name and set it to "public".
* Click "Create project"

Once the mirroring is done you should see your new project. You can now give it a logo or set various setting if you'd like.

## Github Integration in GitLab

Setting up Github integration means that GitLab will be able to report back to Github on the status of builds for your commits and PRs (only those that originate from branches in the main repo, not forks).

* From your new project, hover your mouse over "Settings" in the left sidebar, and select "Integrations".
* Click "Github" from the list.

You'll now need to generate a "Personal access token". This should be done as our Github bot account: [MozmarRobot](https://github.com/MozmarRobot). The credentials for this bot account can be found in our infra private repo. Once logged in as this user go to the [personal access token page](https://github.com/settings/tokens) and create a token named for your new project with the `repo` scope enabled.

* Copy the token and paste it into the field on the Github integration page on GitLab from above.
* Select "active" and enter the Github address for your project.

## GitLab Integration in Github

Integrating GitLab in Github will trigger GitLab's mirroring whenever changes are made to the repo in Github, making things much faster than just relying on GitLab to poll for changes.

* Login to GitLab as our [MozMEAOBot](https://gitlab.com/mozmeaobot) account.
* Go to the [Personal Access Tokens](https://gitlab.com/profile/personal_access_tokens) page.
* Create a token named for the project with the `api` scope.
* Go to the settings for your Github project.
* Add a new webhook.
* Follow the instructions in [Gitlab's docs][gitlab-manual] to create this webhook url based on the token you generated and the project name.
  * It should look like: `https://gitlab.com/api/v4/projects/mozmeao%2F<PROJECT>/mirror/pull?private_token=<PERSONAL_ACCESS_TOKEN>`

## Slack Notifications

Sending notifications to a slack channel is optional but recommended. To do this you'll need the URL for our Slack GitLab webhook integration which you can find in the infra private repo.

* Enable the "Slack notifications" integration in the same place you found the Github one above.
* Paste in the webhook integration for our Slack instance.
* Enable only those events you care about and specify the channel they should report to. It's a good idea to keep these notifications to a project-specific channel.

## Pipeline

Now that you've got all of the wiring done, you can add a `.gitlab-ci.yml` file to your repo and get started. You can see examples in Kitsune and Bedrock. Our runner has many of the same authenticated resources available as our Jenkins box did. Contact a MEAO SRE for details if you don't see an example of what you need in an existing project.

## Troubleshooting

The main issue so far has been that the bot account on Github might not have write permissions to the Github project, which it will need in order to set statuses. Add the `MozmarRobot` account to your project as a writer if you are not seeing commit statuses reported from GitLab.

[GitLab Runner]: https://docs.gitlab.com/runner/
[GitLab Group]: https://gitlab.com/mozmeao
[gitlab-manual]: https://docs.gitlab.com/ee/ci/ci_cd_for_external_repos/github_integration.html#connect-manually
