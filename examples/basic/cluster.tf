module "cluster" {
  source  = "vistaprint/simple-eks/aws"
  version = "0.3.3"

  cluster_name       = "simple-eks-integration-test-for-eks-node-group"
  cluster_version    = "1.20"
  vpc_name           = var.vpc_name
  log_group_name     = "a-test-log-group-name"

  region  = var.aws_region
  profile = var.aws_profile
}

module "spot_node_group" {
  source  = "../.."

  cluster_name       = "simple-eks-integration-test-for-eks-node-group"
  node_group_name    = "spot"
  node_group_version = "1.20"
  use_spot_instances = true

  instance_types = [
    "t3a.medium",
    "t3a.large",
    "t3a.xlarge",
    "t3a.2xlarge",
  ]

  scaling_config = {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  worker_role_arn = module.cluster.worker_role_arn
  subnet_ids      = module.cluster.private_subnet_ids

  use_calico_cni = false

  region  = var.aws_region
  profile = var.aws_profile

  depends_on = [module.cluster]
}
