# K8s node package upgrades

## Overview

The Python 3 script in this directory generates a list of commands that can be manually run to upgrade packages on a set of Kubernetes nodes. 

The upgrade steps on each node are as follows:

1. Attempt to connect to the node via ssh. This ensures that the firewall is open and that we can accept the SSH key before the upgrade occurs.
2. Drain/cordon the K8s node. This often produces warnings about DeamonSets. Sit back, grab a cold beverage, and say "YOLO" out loud before proceeding.
3. Delete any running pods. The drain command in K8s 1.7+ will automatically evict pods, while older clusters stare back at you with a blank expression. It's (mostly) harmless to run.
4. Perform `apt update`, `apt upgrade -y` and `reboot` via ssh connection.
5. Wait for ssh to come back online with `urlwait`.
6. Uncordon the node. The node may still be in an `NotReady` state as the kubelet is starting up, but it should change to `Ready` at which point pods will be scheduled to run.

## Usage

Running the Python script generates a set of commands that you can then run
manually to upgrade each node in the cluster. 

> Please take snapshots of the 3 EBS volumes on a master before running. Taking these snapshots can take 30+ minutes.

```
# set KUBECONFIG or modify the code the set your context appropriately
pip install -r requirements.txt
# the next command generates a list of commands that you need to run manually
python3 generate_update_nodes.py
# now execute each command when ready
```

> It's helpful to run `watch kubectl get nodes` in another window while upgrades are running.

Example output:

```
$ python3 generate_update_nodes.py
# Workers:
./upgrade_node.sh 41.134.142.41 ip-172-22-32-202.us-west-2.compute.internal;
./upgrade_node.sh 41.134.142.42 ip-172-22-32-22.us-west-2.compute.internal;
./upgrade_node.sh 41.134.142.43 ip-172-22-52-229.us-west-2.compute.internal;
./upgrade_node.sh 41.134.142.44 ip-172-22-51-19.us-west-2.compute.internal;
./upgrade_node.sh 41.134.142.45 ip-172-22-53-245.us-west-2.compute.internal;
##################################################
# Masters:
./upgrade_node.sh 41.134.142.46 ip-172-22-59-121.us-west-2.compute.internal;
```

