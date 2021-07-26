output "node_group_id" {
  value = module.spot_node_group.id
}

output "node_group_autoscaling_group_name" {
  value = module.spot_node_group.autoscaling_group_name
}
