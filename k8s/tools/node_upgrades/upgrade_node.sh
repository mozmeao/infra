#!/bin/bash

ssh_username="admin"
max_wait_seconds=300

delete_node_pods() {
    k8s_node_name=$1
    pod_deletes=$(kubectl get pods --all-namespaces -o wide | grep $k8s_node_name | awk '{ print "kubectl -n " $1 " delete pod " $2 ";" }')
    eval $pod_deletes
}

upgrade_node() {
    echo "Making sure we can connect via ssh"
    # do this check so we can accept the ssh key before doing anything else!
    ssh -t $ssh_username@$public_node_ip 'exit'
    kubectl drain $k8s_node_name --force --ignore-daemonsets=true
    delete_node_pods $k8s_node_name
    echo "Connecting via: $ssh_username@$public_node_ip"
    echo "Updating packages"
    ssh -t $ssh_username@$public_node_ip 'sudo apt update'
    echo "Upgrading packages"
    ssh -t $ssh_username@$public_node_ip 'sudo apt upgrade -y'
    echo "Rebooting"
    ssh -o "ServerAliveInterval 2" $ssh_username@$public_node_ip "sudo reboot"
    echo "Waiting for node to come back online:"
    urlwait "tcp://$public_node_ip:22" $max_wait_seconds
    echo "Node has rebooted!"
    kubectl uncordon $k8s_node_name
}

public_node_ip=$1
k8s_node_name=$2
if [[ -z "${public_node_ip}" ]]; then
    echo "Pleast pass in a public_node_ip value"
    exit 1
fi
if [[ -z "${k8s_node_name}" ]]; then
    echo "Pleast pass in a k8s_node_name value"
    exit 1
fi

if ! command -v urlwait > /dev/null; then
    echo "Please install urlwait"
    exit 1
fi
upgrade_node $public_node_ip $k8s_node_name