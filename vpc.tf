data "aws_vpc" "eks_vpc" {
  tags = {
    Name = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.eks_vpc.id

  tags = {
    Type = "Private"
  }
}
