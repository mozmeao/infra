#!/bin/bash

source ../bin/common.sh
check_meao_env

deis create cloudflare-datadog-sync --no-remote
deis perms:create travis -a cloudflare-datadog-sync
deis routing:disable -a cloudflare-datadog-sync

deis pull mozmeao/cloudflare-datadog:32dd3d6539131dff444239d235ad2e79fb498bc9
