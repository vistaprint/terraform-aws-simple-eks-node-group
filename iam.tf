data "aws_iam_role" "worker_role" {
  name = "${data.aws_eks_cluster.cluster.id}-eks-worker-role"
}
