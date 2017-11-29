#!/bin/bash -e

# env vars:
# DBTYPE: accepts either of the following values: MYSQL or PGSQL
# DBNAME: name of database to use in connection string
# DBUSER: MySQL OR Postgres username
# DBPASSWORD: MySQL OR Postgres password
# DBHOST: MySQL OR Postgres host without port#
# DBPORT: MySQL OR Postgres port #
# BACKUP_CMD_PARAMS: additional parameters to pass to backup command for psql/mysql
# BACKUP_BUCKET: where to write backup file, includes s3:// prefix
# BACKUP_DIR: directory in the container mapped to EBS volume
# BACKUP_PASSWORD: symmetric encryption password
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

check_requirements() {
    if [[ -z $DBHOST || -z $DBNAME || -z $DBPASSWORD \
          || -z $DBPORT || -z $DBTYPE || -z $DBUSER || -z $BACKUP_DIR \
          || -z $BACKUP_PASSWORD ]]; then
        echo "ERROR: Not all environment variables are set."
        echo "Minimum required vars:"
        echo "  DBHOST"
        echo "  DBNAME"
        echo "  DBPASSWORD"
        echo "  DBPORT"
        echo "  DBTYPE"
        echo "  DBUSER"
        echo "  BACKUP_DIR"
        echo "  BACKUP_PASSWORD"
        exit 1
    fi
}

fix_creds() {
    # use a ~/.aws/credentials file INSTEAD of k8s set environment vars.
    # Unset env vars after the file is written.
    # Creds containing a slash seem to break the AWS CLI when run inside k8s,
    # but running in docker is fine.
    #
    # example error:
    # fatal error: Invalid header value b'AWS AKIAXXXX\n:ri81t84+26rX0qzRAASDDDXXXy2B70='
    mkdir "${HOME}"/.aws
    cat << EOF > "${HOME}"/.aws/credentials
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
EOF
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
}

push_to_s3() {
    REMOTE_DIR="${BACKUP_BUCKET}/${DBNAME}/"
    echo "Pushing ${ENCRYPTED_BACKUP_FILENAME} to ${REMOTE_DIR}"
    aws s3 cp "${ENCRYPTED_BACKUP_FILENAME}" "${REMOTE_DIR}"
    echo "Finished pushing to S3"
}

postgres_backup() {
    echo "Starting Postgresql backup on $(date)"
    export PGUSER="${DBUSER}"
    export PGPASSWORD="${DBPASSWORD}"
    export PGHOST="${DBHOST}"
    export PGPORT="${DBPORT}"
    export PGDATABASE="${DBNAME}"
    pg_dump "${DBNAME}" \
        | gzip \
        | openssl aes-256-cbc -e -salt \
            -out ${ENCRYPTED_BACKUP_FILENAME} \
            -pass "env:BACKUP_PASSWORD"
    echo "Finished Postgresql backup on $(date)"
}

mysql_backup() {
    echo "Starting MySQL backup on $(date)"
    export MYSQL_PWD="${DBPASSWORD}"
    mysqldump -u${DBUSER} \
              -h${DBHOST} \
              -P${DBPORT} \
              ${MYSQL_BACKUP_OPTIONS} "${DBNAME}" \
        | gzip  \
        | openssl aes-256-cbc -e -salt \
            -out ${ENCRYPTED_BACKUP_FILENAME} \
            -pass "env:BACKUP_PASSWORD"
    echo "Finished MySQL backup on $(date)"
}

perform_backup() {
    cd ${BACKUP_DIR}
    mkdir -p ${DBNAME}
    cd ${DBNAME}

    echo "Encrypted backup output file: ${ENCRYPTED_BACKUP_FILENAME}"

    if [[ "${DBTYPE}" == "PGSQL" ]]; then
        postgres_backup
    elif [[ "${DBTYPE}" == "MYSQL" ]]; then
        mysql_backup
    else
        echo "DBTYPE must be PGSQL or MYSQL"
        exit 1
    fi
}

notify_deadmanssnitch() {
    if [[ -z "${DEADMANSSNITCH_URL}" ]]; then
        echo "DEADMANSSNITCH_URL is not configured"
    else
        echo "updating Deadmanssnitch: ${DEADMANSSNITCH_URL}"
        curl "${DEADMANSSNITCH_URL}"
        echo "Deadmanssnitch updated"
    fi
}

export MYSQL_BACKUP_OPTIONS="${BACKUP_CMD_PARAMS:- --dump-date --compress --single-transaction}"
export PGSQL_BACKUP_OPTIONS="${BACKUP_CMD_PARAMS:- }"

export BACKUP_OUTPUT_DIR="${BACKUP_DIR}/${DBNAME}"
export BASE_FILENAME="${DBNAME}.$( date +%F ).sql.gz"
export BACKUP_FILENAME="${BACKUP_OUTPUT_DIR}/${BASE_FILENAME}"
export ENCRYPTED_BACKUP_FILENAME="${BACKUP_FILENAME}.aes"

if [ -e ${ENCRYPTED_BACKUP_FILENAME} ]
then
    echo "Encrypted file ${ENCRYPTED_BACKUP_FILENAME} already exists, exiting."
    exit 1
fi

echo "${DBNAME} backup started at $(date)"
check_requirements
fix_creds
perform_backup
push_to_s3
notify_deadmanssnitch
echo "${DBNAME} backup finished at $(date)"


