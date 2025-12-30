module "node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.8.3"

  name         = "ecommerce-node-group"
  cluster_name = module.eks.cluster_name

  subnet_ids = module.vpc.private_subnets

  instance_types = ["t3.medium"]

  min_size     = 2
  max_size     = 4
  desired_size = 2
}
