locals {
  cluster_name    = "simple-eks-integration-test-for-eks-node-group"
  cluster_version = "1.23"
}

module "cluster" {
  source  = "vistaprint/simple-eks/aws"
  version = "0.4.0-rc1"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_name        = var.vpc_name

  region  = var.aws_region
  profile = var.aws_profile
}

module "node_group" {
  source = "../.."

  cluster_name       = local.cluster_name
  node_group_version = local.cluster_version
  node_group_name    = "basic"

  instance_types = ["t3a.small"]

  scaling_config = {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  worker_role_arn = module.cluster.worker_role_arn
  subnet_ids      = module.cluster.private_subnet_ids

  region  = var.aws_region
  profile = var.aws_profile

  depends_on = [module.cluster]
}

module "ebs_encrypted_node_group" {
  source = "../.."

  cluster_name       = local.cluster_name
  node_group_version = local.cluster_version
  node_group_name    = "encrypt-ebs"

  instance_types = ["t3a.small"]

  scaling_config = {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  worker_role_arn = module.cluster.worker_role_arn
  subnet_ids      = module.cluster.private_subnet_ids

  encrypt_ebs = true

  region  = var.aws_region
  profile = var.aws_profile

  depends_on = [module.cluster]
}
