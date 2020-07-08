# Github -> Gitlab Mirroring

## Public Repositories

For public repositories GitLab can automatically sync changes from a Github repo. 

Steps:
 - Go to Gitlab Repository
 - Select `Settings` -> `Repository`
 - Select `Mirroring repositories`
 - Add a link to the Github repository 
 
## Private Repositories

To mirror private repositories, setup a Github Action to push changes to GitLab automatically.

Steps:
 - Go to GitLab Repository
 - Select `Settings` -> `Repository`
 - Select `Deploy Keys` 
 - Enable `Gitlab Github Sync` Key from the `Privately accessible deploy keys` list
 - Edit the enabled key and check `Allow writes` checkbox
 - Go to Github Repository
 - Select `Settings` -> `Secrets` -> `Add key`
 - Name the new key `GITLAB_SSH_PRIVATE_KEY` and paste the contents of `infra-private/ssh/github-gitlab-sync`
 - Create a Github Actions Workflow by copying https://github.com/mozmeao/aws-cleanup/blob/master/.github/workflows/main.yml to your repo. Make sure to edit the repository name in line 13 to match your repository in GitLab.
 
 
