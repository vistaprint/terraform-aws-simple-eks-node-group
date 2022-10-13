data "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  lifecycle {
    postcondition {
      condition     = self.kubernetes_network_config[0].ip_family == "ipv6" || !var.enable_high_pod_density
      error_message = "High pod density can only be enabled with IPv6-based clusters"
    }
  }
}
