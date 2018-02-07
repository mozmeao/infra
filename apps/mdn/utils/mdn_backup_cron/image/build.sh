#!/bin/bash
GIT_COMMIT_RAW=$(git rev-parse HEAD)
GIT_COMMIT=${GIT_COMMIT_RAW:0:7}
docker build -t quay.io/mozmar/mdn-backup:${GIT_COMMIT} .
docker push quay.io/mozmar/mdn-backup:${GIT_COMMIT}
