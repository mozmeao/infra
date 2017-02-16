#!/bin/bash

set -e

if [ -z "${AWS_USER}" ]; then
    echo "Please set the AWS_USER environment variable"
    exit 1
fi

AWS_SSH_KEYNAME="${AWS_USER}.ssh"
AWS_REGION="us-east-2"
: "${EC2_INSTANCE_SIZE:=t2.medium}"
: "${SSH_PUBLIC_KEY_FILE:=~/.ssh/id_rsa.pub}"
: "${SSH_PRIVATE_KEY_FILE:=~/.ssh/id_rsa}"
# Default to Ubuntu Server 16.04 LTS (HVM), SSD Volume Type for us-east-2
# https://aws.amazon.com/ec2/instance-types/
: "${EC2_AMI:=ami-fcc19b99}"

# expand the tilde
eval SSH_PUBLIC_KEY_FILE=$SSH_PUBLIC_KEY_FILE
eval SSH_PRIVATE_KEY_FILE=$SSH_PRIVATE_KEY_FILE

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CLEAR='\033[0m'

echo_blue() {
    echo -e "${BLUE}$1${CLEAR}"
}

echo_red() {
    echo -e "${RED}$1${CLEAR}"
}

echo_green() {
    echo -e "${GREEN}$1${CLEAR}"
}

echo_yellow() {
    echo -e "${YELLOW}$1${CLEAR}"
}

app_banner() {
cat << "EOF"
   __  __        __  __ ___   _   ___
 |  \/  |___ __|  \/  | __| /_\ / _ \
 | |\/| / _ \_ / |\/| | _| / _ \ (_) |
 |_|_ |_\___/__|_|  |_|___/_/ \_\___/
 | __/ __|_  ) (_)_ _  __| |_ __ _ _ _  __ ___
 | _| (__ / /  | | ' \(_-<  _/ _` | ' \/ _/ -_)
 |___\___/___| |_|_||_/__/\__\__,_|_||_\__\___|
 | |__ _ _  _ _ _  __| |_  ___ _ _
 | / _` | || | ' \/ _| ' \/ -_) '_|
 |_\__,_|\_,_|_||_\__|_||_\___|_|
EOF
echo ""
}

# ensure dependencies are on the PATH
check_deps() {
    set +e
    echo "Checking for dependencies:"
    echo -n "  aws... "
    which aws > /dev/null
    if [ $? -ne 0 ]; then
        echo ""
        echo_red "You don't seem to have the aws cli installed, or it's not on your path"
        echo ""
        echo "If you're on OSX, try:"
        echo "brew install awscli"
        echo "Please visit https://aws.amazon.com/cli/ for more info"
        exit 1
    else
        echo_green '\o/'
    fi

    echo -n "  jq... "
    which jq > /dev/null
    if [ $? -ne 0 ]; then
        echo ""
        echo_red "You don't seem to have jq installed, or it's not on your path"
        echo ""
        echo "If you're on OSX, try:"
        echo "brew install jq"
        echo "Please visit https://stedolan.github.io/jq/ for more info"
        exit 1
    else
        echo_green '\o/'
    fi
    set -e
}

# try to describe instances in a region
# if it fails, ~/.aws/credentials is probably setup incorrectly
aws_smoke_test() {
    echo -n "Verifying AWS credentials work... "
    aws ec2 describe-instances --region "${AWS_REGION}" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo_green '\o/'
    else
        echo ":-("
        echo "You don't seem to have the AWS cli setup correctly"
        echo "Please visit https://aws.amazon.com/cli/ for more info"
        exit 1
    fi
}

# upload a public ssh key for the current $AWS_USER
upload_public_ssh_key() {
    echo -n "Uploading $SSH_PUBLIC_KEY_FILE to AWS... "
    # tilde must be expanded here
    SSH_PUB_KEY=$(< $SSH_PUBLIC_KEY_FILE)
    # ignore duplicate upload failures
    set +e
    IMPORT_OUTPUT=$(aws ec2 import-key-pair \
                        --key-name "${AWS_SSH_KEYNAME}" \
                        --public-key-material "${SSH_PUB_KEY}" \
                        --region "${AWS_REGION}" 2>&1)
    if [ $? -ne 0 ]; then
        DUP_COUNT=$(grep -c "Duplicate" <<< "${IMPORT_OUTPUT}")
        if [ $DUP_COUNT -ne 0 ]; then
            echo_yellow "Key already exists"
        else
            echo_red "Error uploading key:"
            echo "${IMPORT_OUTPUT}"
        fi
    else
        echo_green '\o/'
    fi
}

# wait for the public IP of the new instance to become available
wait_for_public_ip() {
    IP_QUERY="aws ec2 describe-instances --region ${AWS_REGION} | "
    IP_QUERY+="jq -r '.Reservations[].Instances[] | "
    IP_QUERY+="select(.InstanceId==\"${EC2_INSTANCE_ID}\") | .PublicIpAddress'"

    EC2_PUBLIC_IP=$(eval "${IP_QUERY}")
    EC2_PUBLIC_IP=" "
    DOT_COUNT=$(grep -c "\." <<< "${EC2_PUBLIC_IP}")
    until [ $DOT_COUNT -ne 0 ]; do
        echo -n "."
        sleep 1
        EC2_PUBLIC_IP=$(eval "${IP_QUERY}")
        DOT_COUNT=$(grep -c "\." <<< "${EC2_PUBLIC_IP}")
    done
}

# create and tag a new instance
run_instance() {
    echo -n "Launching instance... "
    EC2_INSTANCE=$(aws ec2 run-instances \
        --image-id "${EC2_AMI}" \
        --count 1 \
        --instance-type "${EC2_INSTANCE_SIZE}" \
        --key-name "${AWS_SSH_KEYNAME}" \
        --region "${AWS_REGION}" \
        --security-groups developers_allow_all)

    EC2_INSTANCE_ID=$(jq -r .Instances[0].InstanceId <<< "${EC2_INSTANCE}")
    echo_green '\o/'

    echo -n "Waiting for a public IP..."
    # wait a few seconds up front
    wait_for_public_ip
    echo_green ' \o/'

    echo -n "Tagging instances... "
    aws ec2 create-tags --resources "${EC2_INSTANCE_ID}" \
        --tags "Key=CreatedBy,Value=${AWS_USER}" \
        --region "${AWS_REGION}"
    DATE_STAMP=$(date +"%y-%m-%d")
    INSTANCE_TAG_NAME="${AWS_USER}-dev-${DATE_STAMP}"

    aws ec2 create-tags --resources "${EC2_INSTANCE_ID}" \
        --tags "Key=Name,Value=${INSTANCE_TAG_NAME}" \
        --region "${AWS_REGION}"
    echo_green ' \o/'
}

footer() {
    echo ""
    echo_blue "Your instance has been successfully created:"
    echo_blue "  EC2 instance ID: ${EC2_INSTANCE_ID}"
    echo_blue "  Instance name: ${INSTANCE_TAG_NAME}"
    echo_blue "  Public ip: ${EC2_PUBLIC_IP}"
    echo_blue "  Remote key name: ${AWS_SSH_KEYNAME}"
    echo "  Note: although the remote key name doesn't match your local "
    echo "        key name, the contents will container either:"
    echo "        - ~/.ssh/id_rsa.pub"
    echo "           OR"
    echo "        - \$SSH_PUBLIC_KEY_FILE if you specified it before"
    echo "              launching an instance (as mentioned in the docs)"
    echo ""
    echo "To connect, wait a few minutes for the instance to finish spinning up,"
    echo "and then run:"
    echo "ssh -i ${SSH_PRIVATE_KEY_FILE} ubuntu@${EC2_PUBLIC_IP}"
    echo ""
    echo "To stop the instance:"
    echo "aws ec2 stop-instances --instance-ids \"${EC2_INSTANCE_ID}\" --region \"${AWS_REGION}\""
    echo ""
    echo "To (re)start the instance:"
    echo "aws ec2 start-instances --instance-ids \"${EC2_INSTANCE_ID}\" --region \"${AWS_REGION}\""
    echo ""
    echo "To terminate the instance:"
    echo "aws ec2 terminate-instances --instance-ids \"${EC2_INSTANCE_ID}\" --region \"${AWS_REGION}\""
    echo ""
}

app_banner
check_deps
aws_smoke_test
upload_public_ssh_key
run_instance
footer



