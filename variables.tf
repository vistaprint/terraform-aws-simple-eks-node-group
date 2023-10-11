variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "node_group_version" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "scaling_config" {
  type = object({
    desired_size = number,
    max_size     = number,
    min_size     = number
  })
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "use_spot_instances" {
  type    = bool
  default = false
}

variable "architecture" {
  type    = string
  default = "x86_64"

  validation {
    condition     = var.architecture == "x86_64" || var.architecture == "arm64"
    error_message = "Invalid value for architecture (must be x86_64 or arm64)."
  }
}

variable "image_id" {
  type    = string
  default = null

  description = "AMI id to use for the node group"
}

variable "worker_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "enable_high_pod_density" {
  type    = bool
  default = false

  description = <<-EOT
    Nodes in EKS clusters can only host a limited amount of pods. The number
    of network interfaces in an EC2 instance is what introduces this limit.
    As this limit is quite small (e.g., 29 pods for an m5.large instance), AWS
    came up with a solution (prefix delegation) to increase the pod density in
    EKS nodes.

    By enabling this option, each node will be able to host a signficantly
    larger amount of pods (e.g., 110 pods for an m5.large instance).

    While prefix delegation works for IPv4-based clusters, this module chooses
    to only support it for IPv6-based ones, for simplicity reasons.

    For more details see:
      - https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/
      - https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
  EOT
}

variable "encrypt_ebs" {
  type    = bool
  default = true
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "launch_template_custom_userdata" {
  type        = string
  description = "Extra configuration executed after bootstraping the node"
  default     = ""
}
