locals {
  capacity_type = var.use_spot_instances ? "SPOT" : "ON_DEMAND"
  ami_type      = var.architecture == "x86_64" ? "AL2_x86_64" : "AL2_ARM_64"
}
