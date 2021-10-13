locals {
  is_launch_template_needed = var.use_calico_cni || var.encrypt_ebs || var.volume_type != null

  x86_64_ami = "amazon-eks-node-${var.node_group_version}-v*"
  arm64_ami  = "amazon-eks-arm64-node-${var.node_group_version}-v*"
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = var.architecture == "x86_64" ? local.x86_64_ami : local.arm64_ami
  owners      = ["amazon"]
}

resource "aws_launch_template" "worker_nodes" {
  count = local.is_launch_template_needed ? 1 : 0

  name = "${var.cluster_name}-${var.node_group_name}"

  image_id = data.aws_ami.ami.id

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = var.volume_type
      delete_on_termination = true
      encrypted             = var.encrypt_ebs
      kms_key_id            = var.encrypt_ebs ? aws_kms_key.ebs_encryption_key[0].arn : null
    }
  }

  network_interfaces {
    device_index    = 0
    security_groups = [data.aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id]
  }

  ebs_optimized = false

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  dynamic "tag_specifications" {
    for_each = length(var.tags) > 0 ? ["instance", "volume"] : []
    content {
      resource_type = tag_specifications.value
      tags          = var.tags
    }
  }

  user_data = base64encode(templatefile("${path.module}/data/userdata.tpl", {
    cluster_name               = var.cluster_name
    cluster_endpoint           = data.aws_eks_cluster.cluster.endpoint
    certificate_authority_data = data.aws_eks_cluster.cluster.certificate_authority[0].data
    bootstrap_extra_args       = var.use_calico_cni ? "--use-max-pods false" : ""
    disable_source_dest_checks = var.use_calico_cni
    ami_id                     = data.aws_ami.ami.id
    node_group_name            = var.node_group_name
    capacity_type              = local.capacity_type
  }))
}
