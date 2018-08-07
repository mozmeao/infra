output "cluster_name" {
  value = "k8s.us-west-2.mdn.mozit.cloud"
}

output "master_security_group_ids" {
  value = [ "${module.kubernetes.master_security_group_ids}" ]
}

output "node_security_group_ids" {
  value = [ "${module.kubernetes.node_security_group_ids}" ]
}

output "node_subnet_ids" {
  value = [ "${module.kubernetes.node_subnet_ids}" ]
}

output "vpc_id" {
  value = "${module.kubernetes.vpc_id}"
}

