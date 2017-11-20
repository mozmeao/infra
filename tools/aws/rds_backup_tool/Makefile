# namespace where all backup pods run and secrets are installed
export K8S_NAMESPACE ?= rds-backups
# region global secrets, see README.md for more info
export BACKUP_CONFIG_SECRETS ?= rds-backup-config
# dir inside the container to use for backups
export BACKUP_DIR ?= /backup
# s3 bucket and subdir to push encrypted backups to
# note: a subdirectory is automatically created with the name of the
# database (DBNAME) to store a given DBNAME's backups.
export BACKUP_BUCKET ?= s3://meao-rds-backups/backups
# set this value to true to prevent the main backup script from running
# used to get a shell in a container for debugging. See README.md for more info.
export DEBUG_MODE ?= false
# automatically append month-year-date to new pod names
export BACKUP_POD_SUFFIX ?= $(shell date +%F)
export RDSBACKUP_IMAGE_TAG ?= dea4aed62d8f2d77c91c19022488e246fd1eded2
export RDS_IMAGE ?= quay.io/mozmar/rdsbackup:${RDSBACKUP_IMAGE_TAG}
# the command to use to render yaml and create pod in k8s
export RENDER_POD_CMD ?= j2 rds_backup_pod.yaml.j2 | kubectl create -n ${K8S_NAMESPACE} -f -

default:
	echo "Please select a target"

backup-mdn-prod-rr:
	env DBTYPE=MYSQL \
		DB_SECRETS_NAME=rds-backup-mdn-prod \
		BACKUP_POD_NAME=mdn-prod-rr \
	${RENDER_POD_CMD}

backup-frankfurt:
	env DBTYPE=PGSQL \
		DB_SECRETS_NAME=rds-backup-frankfurt \
		BACKUP_POD_NAME=frankfurt \
	${RENDER_POD_CMD}

