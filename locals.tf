locals {
  requirements = compact([
    var.instance_categories != null ? {
      key      = "eks.amazonaws.com/instance-category"
      operator = "In"
      values   = var.instance_categories
    } : null,
    var.instance_cpus != null ? {
      key      = "eks.amazonaws.com/instance-cpu"
      operator = "In"
      values   = var.instance_cpus
    } : null,
    var.availability_zones != null ? {
      key      = "topology.kubernetes.io/zone"
      operator = "In"
      values   = var.availability_zones
    } : null,
    {
      key      = "kubernetes.io/arch"
      operator = "In"
      values   = var.instance_architectures
    }
  ])
}
