variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "node_pool_name" {
  type = string
}

variable "cpu_limit" {
  type = string
}

variable "memory_limit" {
  type = string
}

variable "instance_categories" {
  type        = set(string)
  default     = null
  description = "Set of instance categories to use for the node pool. If null, no instance category constraint will be applied."
}

variable "instance_cpus" {
  type        = set(string)
  default     = null
  description = "Set of instance CPU counts to use for the node pool. If null, no CPU constraint will be applied."
}

variable "instance_architectures" {
  type        = set(string)
  default     = ["arm64", "amd64"]
  description = "Set of instance architectures to support"

  validation {
    condition = alltrue([
      for arch in var.instance_architectures : contains(["arm64", "amd64"], arch)
    ])
    error_message = "Instance architectures must only contain 'arm64' and/or 'amd64'."
  }

  validation {
    condition     = length(var.instance_architectures) > 0
    error_message = "At least one architecture must be specified."
  }
}

variable "availability_zones" {
  type        = set(string)
  default     = null
  description = "Set of availability zones to use for the node pool. If null, no zone constraint will be applied."
}

# variable "tags" {
#   type    = map(string)
#   default = {}
# }
