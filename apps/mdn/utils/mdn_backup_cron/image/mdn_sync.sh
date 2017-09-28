#!/bin/bash -e

check_requirements() {
    if [[ -z $LOCAL_DIR || -z $REMOTE_DIR || -z $BUCKET || -z $PUSH_OR_PULL || -z $AWS_REGION ]]; then
        echo "Not all environment variables are set"
        exit 1
    fi
}

SYNC_COMMAND="${AWS_SYNC_COMMAND:-aws s3 sync}"
PAGE_SIZE="${AWS_S3SYNC_PAGE_SIZE:-100}"

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
    echo "Pushing from ${LOCAL_DIR} to ${BUCKET}${REMOTE_DIR}"
    ${SYNC_COMMAND} "${LOCAL_DIR}" "${BUCKET}${REMOTE_DIR}" --page-size ${PAGE_SIZE} --region "${AWS_REGION}"
    echo "Complete"
}

pull_from_s3() {
    echo "Pulling from ${BUCKET}${REMOTE_DIR} to ${LOCAL_DIR}"
    ${SYNC_COMMAND} "${BUCKET}${REMOTE_DIR}" "${LOCAL_DIR}" --page-size ${PAGE_SIZE} --region  "${AWS_REGION}"
    echo "Complete"
}

check_requirements
fix_creds

if [[ "${PUSH_OR_PULL}" == "PUSH" ]]; then
    push_to_s3
elif [[ "${PUSH_OR_PULL}" == "PULL" ]]; then
    pull_from_s3
else
    echo "Invalid PUSH_OR_PULL value"
    exit 1
fi

if [[ -z "${DEADMANSSNITCH_URL}" ]]; then
    echo "DEADMANSSNITCH_URL is not configured"
else
    echo "updating Deadmanssnitch: ${DEADMANSSNITCH_URL}"
    curl "${DEADMANSSNITCH_URL}"
    echo "Deadmanssnitch updated"
fi

