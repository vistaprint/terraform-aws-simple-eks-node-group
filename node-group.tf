resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.worker_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }

  instance_types = var.instance_types
  capacity_type  = local.capacity_type
  version        = var.use_calico_cni ? null : var.node_group_version
  ami_type       = var.use_calico_cni ? null : local.ami_type

  dynamic "launch_template" {
    for_each = var.use_calico_cni ? [1] : []
    content {
      id      = aws_launch_template.worker_nodes[0].id
      version = aws_launch_template.worker_nodes[0].latest_version
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ingores changes to scaling_config.desired_size.
      #
      # If cluster autoscaler changes the number of nodes, terraform will try
      # to adjust that number when updating the resource. This is something
      # most likely undesirable.
      #
      # Ideally we could do this only if var.enable_cluster_autoscaler is set
      # to true, but there is not really an easy way to do so.
      scaling_config[0].desired_size
    ]
  }
}
