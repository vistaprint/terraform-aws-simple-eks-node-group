resource "kubernetes_manifest" "nodepool" {
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = var.node_pool_name
    }
    spec = {
      limits = {
        cpu    = var.cpu_limit
        memory = var.memory_limit
      }
      template = {
        spec = {
          nodeClassRef = {
            group = "eks.amazonaws.com"
            kind  = "NodeClass"
            name  = "default"
          }
          requirements = local.requirements
        }
      }
    }
  }
}
