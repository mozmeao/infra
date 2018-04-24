#!/bin/bash
docker build . -t quay.io/mozmar/blockaws:${GIT_COMMIT:=$(git rev-parse --short HEAD)}
docker push quay.io/mozmar/blockaws:${GIT_COMMIT}
