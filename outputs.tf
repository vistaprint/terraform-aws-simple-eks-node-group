output "id" {
  value = aws_eks_node_group.node_group.id
}

output "autoscaling_group_name" {
  value = aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
}