GIT_COMMIT ?= $(shell git rev-parse HEAD)

all:
	#docker build . -t quay.io/mozmar/rdsbackup:${GIT_COMMIT}
	#docker push quay.io/mozmar/rdsbackup:${GIT_COMMIT}
	docker build . -t metadave/meaocron:latest
