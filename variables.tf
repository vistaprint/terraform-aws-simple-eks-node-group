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

variable "use_calico_cni" {
  type    = bool
  default = false
}

variable "worker_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "encrypt_ebs" {
  type    = bool
  default = true
}

variable "require_http_tokens" {
  type    = bool
  default = true
}
