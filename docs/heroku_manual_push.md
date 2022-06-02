# Push to Bedrock Demos on Heroku

This will go over the basics of deploying a bedrock branch to one of our demo instances on Heroku. You'll basically be following the [Heroku Docs](https://devcenter.heroku.com/articles/git) for deploying via `git push`, but this document will add to that exactly what we've done.

## Install Heroku CLI

See the above link to the Heroku Docs for install and setup. Basically:

```bash
$ brew tap heroku/brew && brew install heroku
```

## Setup Heroku Git Remotes

The push will use git remote definitions to push to the right apps. For example, to push a branch to www-demo2 you'll do `git push heroku-demo2 my-dev-branch:main`. In order to do that we need to setup those remotes.

```bash
$ heroku git:remote -a www-demo1
$ git remote rename heroku heroku-demo1
```

Repeat the above for www-demo2 through www-demo5.

## Deploy

Say someone asks you to deploy the `make-everything-awesomer` branch to demo4. This is the procedure.

```bash
$ git pull origin # if your mozilla remote is "origin"
$ git checkout make-everything-awesomer
$ git push --force heroku-demo4 make-everything-awesomer:main
```

You have to push the `main` branch in order for Heroku to deploy your branch code.

Once you do this you should see the build log in your terminal and it will take a few minutes but once the command returns the deployment should be done.

### NOTES

Before this procedure will work you'll need to login to the Heroku CLI, usually at least once per day. Just do `heroku login` in the CLI, it will open a web page, login, then be ready to go once that is done.

If you try to do a push and it asks you for your Heroku username you just need to `heroku login` and it'll work normally.
