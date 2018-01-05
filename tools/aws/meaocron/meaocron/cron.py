import datetime
import os
import sys
from subprocess import check_call

import requests
from apscheduler.schedulers.blocking import BlockingScheduler
from decouple import config

schedule = BlockingScheduler()
DEAD_MANS_SNITCH_URL = config('DEAD_MANS_SNITCH_URL', default='')

def call_command(command):
    check_call('/bin/bash -c {0}'.format(command), shell=True)

class scheduled_job(object):
    """Decorator for scheduled jobs. Takes same args as apscheduler.schedule_job."""

    def __init__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs

    def __call__(self, fn):
        self.name = fn.__name__
        self.callback = fn
        schedule.add_job(self.run, id=self.name, *self.args, **self.kwargs)
        self.log('Registered')
        return self.run

    def run(self):
        self.log('starting')
        try:
            self.callback()
        except Exception as e:
            self.log('CRASHED: {}'.format(e))
            raise
        else:
            self.log('finished successfully')

    def log(self, message):
        msg = '[{}] Clock job {}: {}'.format(
            datetime.datetime.utcnow(), self.name, message)
        print(msg, file=sys.stderr)


def ping_dms(function):
    """Pings Dead Man's Snitch after job completion if URL is set."""

    def _ping():
        function()
        if DEAD_MANS_SNITCH_URL:
            utcnow = datetime.datetime.utcnow()
            payload = {'m': 'Run {} on {}'.format(function.__name__, utcnow.isoformat())}
            requests.get(DEAD_MANS_SNITCH_URL, params=payload)

    _ping.__name__ = function.__name__
    return _ping


def schedule_backup_jobs():
    @scheduled_job('interval', minutes=1)
    def show_the_date():
        call_command('date')

# TODO:
# 0. Kickoff DB backups scheduled_job
#   I need to think about how this is going to work
#   it's in the same repo, but generated using a Makefile + j2 on the CLI
#   consider rendering the yaml template from Python instead of make
# 1. asgcheck scheduled_job
#   needs a region, slack api token, slack channel name as params (env?)
# 2. snapshot cleanup scheduled_job
#   needs region, volumes(s), days_to_keep, slack info 

if __name__ == '__main__':
    #args = sys.argv[1:]
    schedule_backup_jobs()
    try:
        schedule.start()
    except (KeyboardInterrupt, SystemExit):
        pass