resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.worker_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = var.node_instance_types
}

resource "aws_iam_role" "worker_role" {
  name = "${var.cluster_name}-worker-role"

  assume_role_policy = data.aws_iam_policy_document.worker_assume_role.json
}

data "aws_iam_policy_document" "worker_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "worker_ECR_ReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_role.name
}

