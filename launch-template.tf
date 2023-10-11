locals {
  is_launch_template_needed = var.encrypt_ebs || var.volume_type != null

  x86_64_ami = "amazon-eks-node-${var.node_group_version}-v*"
  arm64_ami  = "amazon-eks-arm64-node-${var.node_group_version}-v*"

  ami_id = var.image_id != null ? var.image_id : data.aws_ami.ami.0.id

  node_labels = "--node-labels=${join(",", [
    "eks.amazonaws.com/nodegroup-image=${local.ami_id}",
    "eks.amazonaws.com/capacityType=${local.capacity_type}",
    "eks.amazonaws.com/nodegroup=${var.node_group_name}"
  ])}"

  kubelet_extra_args = "--kubelet-extra-args '${join(" ", concat(
    [local.node_labels],
    # TODO: instances with more than 30 vCPUs have a larger value for max-pods.
    #  Let's compute the value instead of hardcoding it.
    #  (see https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/)
    var.enable_high_pod_density ? ["--max-pods=110"] : []
  ))}'"

  kubernetes_network_config = data.aws_eks_cluster.cluster.kubernetes_network_config[0]

  bootstrap_extra_args = join(" ", concat(
    var.enable_high_pod_density ? ["--use-max-pods false"] : [],
    local.kubernetes_network_config.ip_family == "ipv6" ? ["--ip-family ipv6"] : [],
    local.kubernetes_network_config.ip_family == "ipv6" ? ["--service-ipv6-cidr ${local.kubernetes_network_config.service_ipv6_cidr}"] : [],
    [local.kubelet_extra_args]
  ))
}

data "aws_ami" "ami" {
  count = var.image_id == null ? 1 : 0

  most_recent = true
  name_regex  = var.architecture == "x86_64" ? local.x86_64_ami : local.arm64_ami
  owners      = ["amazon"]
}

resource "aws_launch_template" "worker_nodes" {
  count = local.is_launch_template_needed ? 1 : 0

  name = "${var.cluster_name}-${var.node_group_name}"

  image_id = local.ami_id

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
    http_protocol_ipv6          = local.kubernetes_network_config.ip_family == "ipv6" ? "enabled" : "disabled"
  }

  dynamic "tag_specifications" {
    for_each = length(var.tags) > 0 ? ["instance", "volume"] : []
    content {
      resource_type = tag_specifications.value
      tags          = var.tags
    }
  }

  user_data = base64encode(templatefile("${path.module}/data/userdata.tpl", {
    cluster_name                    = var.cluster_name
    cluster_endpoint                = data.aws_eks_cluster.cluster.endpoint
    certificate_authority_data      = data.aws_eks_cluster.cluster.certificate_authority[0].data
    bootstrap_extra_args            = local.bootstrap_extra_args
    launch_template_custom_userdata = var.launch_template_custom_userdata
  }))
}
