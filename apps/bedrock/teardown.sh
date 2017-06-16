#!/bin/bash
deis apps:destroy -a bedrock-prod  --confirm bedrock-prod
deis apps:destroy -a bedrock-stage --confirm bedrock-stage
deis apps:destroy -a bedrock-dev   --confirm bedrock-dev
