#!/bin/bash
wget https://raw.githubusercontent.com/mozmeao/snippets-service/master/Procfile

deis create snippets-admin --no-remote
deis perms:create jenkins -a snippets-admin

deis config:set ALLOWED_HOSTS=snippets-admin.portland.moz.works -a snippets-admin

deis pull mozorg/snippets:06ce45 -a snippets-admin
