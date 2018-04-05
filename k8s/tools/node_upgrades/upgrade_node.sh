#!/bin/bash

ssh_username="admin"
max_wait_seconds=300

delete_node_pods() {
    k8s_node_name=$1
    pod_deletes=$(kubectl get pods --all-namespaces -o wide | grep $k8s_node_name | awk '{ print "kubectl -n " $1 " delete pod " $2 ";" }')
    eval $pod_deletes
}

wait_for_node() {
    echo -n "Waiting for node to rejoin cluster."
    until kubectl get nodes | grep $k8s_node_name | grep -q " Ready"
    do
        echo -n "."
        sleep 2
    done
    echo ""
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
    echo "Waiting for reboot"
    # Hey, I've added a sleep statement to this script. Before you
    # throw tomatoes at me, it's here because the node reboot
    # can happen before K8s registers that the node is NotReady,
    # which leads to uncordining while possibly in an undesirable
    # state. Maybe it's fine, but I'd prefer to wait.
    # While this might be ok, I'd prefer to wait and let K8s
    # do it's thing instead of sneaking 
    sleep 60
    wait_for_node
    echo "Node is ready"
    echo "Uncordoning node"
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

upgrade_node $public_node_ip $k8s_node_name

