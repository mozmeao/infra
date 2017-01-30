#!/bin/bash


if [ -z "${KOPS_NAME}" ]; then
    echo "KOPS_NAME isn't set, have you sourced config.sh?"
    exit -1
fi

if [ -z "${KOPS_REGION}" ]; then
    echo "KOPS_REGION isn't set, have you sourced config.sh?"
    exit -1
fi


which aws > /dev/null
if [ $? -ne 0 ]; then
    echo "This script requires the AWS cli to run"
    exit 1
fi


which jq > /dev/null
if [ $? -ne 0 ]; then
    echo "This script requires jq to run"
    exit 1
fi


show_help() {
    echo "---------------------------------------------"
    echo "You must source config.sh to use this script."
    echo ""
    echo "Show current security groups"
    echo "k8s_ssh_security.sh --show"
    echo ""
    echo "Disable external ssh into K8s:"
    echo "k8s_ssh_security.sh --disable"
    echo ""
    echo "Disable ssh access from this public ip into K8s:"
    echo "k8s_ssh_security.sh --disable --myip"
    echo ""
    echo "Disable ssh access from a specific CIRD into K8s:"
    echo "k8s_ssh_security.sh --disable --cidr=1.2.3.4/16"
    echo ""
    echo "Enable 0.0.0.0/0 ssh access into K8s:"
    echo "k8s_ssh_security.sh --enable"
    echo ""
    echo "Enable ssh access from this public ip into K8s:"
    echo "k8s_ssh_security.sh --enable --myip"
    echo ""
    echo "Enable ssh access from a specific CIRD into K8s:"
    echo "k8s_ssh_security.sh --enable --cidr=1.2.3.4/16"
}

get_security_groups() {
    MASTERS_GROUP_NAME="masters.${KOPS_NAME}"
    NODES_GROUP_NAME="nodes.${KOPS_NAME}"

    # nodes
    MASTERS_QUERY=".SecurityGroups[] | select(.GroupName == \"${MASTERS_GROUP_NAME}\") | .GroupId"
    MASTERS_GROUP_ID=$(aws ec2 describe-security-groups --region ${KOPS_REGION} | jq -r "${MASTERS_QUERY}")

    NODES_QUERY=".SecurityGroups[] | select(.GroupName == \"${NODES_GROUP_NAME}\") | .GroupId"
    NODES_GROUP_ID=$(aws ec2 describe-security-groups --region ${KOPS_REGION} | jq -r "${NODES_QUERY}")
    echo "Masters group: ${MASTERS_GROUP_NAME} : ${MASTERS_GROUP_ID}"
    echo "Nodes group: ${NODES_GROUP_NAME} : ${NODES_GROUP_ID}"
}


show_current_security() {
    get_security_groups
    QUERY=".SecurityGroups[0].IpPermissions[] | {ip_protocol: .IpProtocol, from: .FromPort, to: .ToPort, cidr: .IpRanges[0].CidrIp, groups: [.UserIdGroupPairs[].GroupId]}"
    echo "Master security groups:"
    aws ec2 describe-security-groups --group-id ${MASTERS_GROUP_ID} --region ${KOPS_REGION} | jq -c -r "${QUERY}"
    echo ""
    echo "Nodes security groups:"
    aws ec2 describe-security-groups --group-id ${NODES_GROUP_ID} --region ${KOPS_REGION} | jq -c "${QUERY}"
}

get_my_ip() {
    which dig > /dev/null
    if [ $? -ne 0 ]; then
        echo "This script needs the dig command installed"
        echo "Try this: sudo apt-get install dnsutils"
        exit 1
    fi

    MY_PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com.)
}

enable_ssh() {
    get_security_groups
    if [ ! -z "${MYIP}" ]; then
        get_my_ip
        this_cidr="${MY_PUBLIC_IP}/32"
        echo "Limiting SSH to ${thisip}"
        aws ec2 authorize-security-group-ingress --group-id ${MASTERS_GROUP_ID} --port 22 --protocol tcp --cidr ${this_cidr} --region ${KOPS_REGION}
        aws ec2 authorize-security-group-ingress --group-id ${NODES_GROUP_ID} --port 22 --protocol tcp --cidr ${this_cidr} --region ${KOPS_REGION}
    elif [ ! -z "${CIDR}" ]; then
        aws ec2 authorize-security-group-ingress --group-id ${MASTERS_GROUP_ID} --port 22 --protocol tcp --cidr ${CIDR} --region ${KOPS_REGION}
        aws ec2 authorize-security-group-ingress --group-id ${NODES_GROUP_ID} --port 22 --protocol tcp --cidr ${CIDR} --region ${KOPS_REGION}
    else
        echo "SSH open to 0.0.0.0/0"
        aws ec2 authorize-security-group-ingress --group-id ${MASTERS_GROUP_ID} --port 22 --protocol tcp --cidr 0.0.0.0/0 --region ${KOPS_REGION}
        aws ec2 authorize-security-group-ingress --group-id ${NODES_GROUP_ID} --port 22 --protocol tcp --cidr 0.0.0.0/0 --region ${KOPS_REGION}
    fi
    echo "DONE"
}

disable_ssh() {
    get_security_groups
    echo "Disabling SSH"
    if [ ! -z "${MYIP}" ]; then
        get_my_ip
        this_cidr="${MY_PUBLIC_IP}/32"
        aws ec2 revoke-security-group-ingress --group-id ${MASTERS_GROUP_ID} --port 22 --protocol tcp --cidr ${this_cidr} --region ${KOPS_REGION}
        aws ec2 revoke-security-group-ingress --group-id ${NODES_GROUP_ID} --port 22 --protocol tcp --cidr ${this_cidr} --region ${KOPS_REGION}
    elif [ ! -z "${CIDR}" ]; then
        aws ec2 revoke-security-group-ingress --group-id ${MASTERS_GROUP_ID} --port 22 --protocol tcp --cidr ${CIDR} --region ${KOPS_REGION}
        aws ec2 revoke-security-group-ingress --group-id ${NODES_GROUP_ID} --port 22 --protocol tcp --cidr ${CIDR} --region ${KOPS_REGION}
    else
        aws ec2 revoke-security-group-ingress --group-id ${MASTERS_GROUP_ID} --port 22 --protocol tcp --cidr 0.0.0.0/0 --region ${KOPS_REGION}
        aws ec2 revoke-security-group-ingress --group-id ${NODES_GROUP_ID} --port 22 --protocol tcp --cidr 0.0.0.0/0 --region ${KOPS_REGION}
    fi
    echo "DONE"
}

for arg in "$@"
do
    case $arg in
        --show)
        SHOW=1
        shift
        ;;
        --myip)
        MYIP=1
        shift
        ;;
        --cidr=*)
        CIDR="${arg#*=}"
        shift
        ;;
        --disable)
        ENABLE_SSH=0
        shift
        ;;
        --enable)
        ENABLE_SSH=1
        shift
        ;;
        --help)
        show_help
        exit 0
    esac
done

if [ ! -z "${SHOW}" ]; then
    show_current_security
    exit 0
fi

if [ -z "${ENABLE_SSH}" ]; then
    show_help
    exit 0
fi

if [ "${ENABLE_SSH}" -eq 1 ]; then
    enable_ssh
else
    disable_ssh
fi


