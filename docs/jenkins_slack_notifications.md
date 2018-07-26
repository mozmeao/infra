# Setup Slack Notifications For Your Jenkins Jobs

You can easily send messages to a Slack channel in your jenkins jobs.
The [slack-cli](https://pypi.org/project/slack-cli/) tool is installed
and configured for use as the `meao-jenkins` bot on 
[Mozilla's Slack Instance](https://mozilla.slack.com). Setup for a new
project is simple.

1. Invite the bot to the channel in which you'd like to post messages.
   The attempt to send notification messages will fail if the bot isn't
   in the channel.
2. Call `slack-cli` from your Jenkins scripts.

Various projects handle step 2 differently. You can of course just call
the `slack-cli` command in any way you'd like which will dutifully post
your message to your channel. Or you can use [a custom script](./slack-notify.sh)
like the one in use by bedrock, basket, and others. The easiest thing to
do if you like the notification style from those projects is
to simply take the script linked above and modify it for your needs.

If you'd like to get even more fancy you can check out the
[Slack docs on message formatting](https://api.slack.com/docs/message-formatting).
