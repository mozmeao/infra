from slacker import Slacker

class SlackClient:
    def __init__(self, apitoken, channel, only_errors):
        self.apitoken = apitoken
        self.channel = channel
        self.only_errors = only_errors
        self.slackclient = Slacker(self.apitoken)

    def info(self, msg):
        if not self.only_errors:
            self.slackclient.chat.post_message(self.channel, msg)

    def error(self, msg):
        self.slackclient.chat.post_message(self.channel, msg)