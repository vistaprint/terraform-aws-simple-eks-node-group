data "aws_iam_role" "worker_role" {
  name = "${var.cluster_name}-eks-worker-role"
}
