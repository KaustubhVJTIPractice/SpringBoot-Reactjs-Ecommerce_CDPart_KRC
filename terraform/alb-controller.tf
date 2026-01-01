# ---------- IAM Role via IRSA ----------
module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.0"

  role_name = "ecommerce-eks-alb-controller-role"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    eks = {
      provider_arn = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]
    }
  }

  depends_on = [
    aws_iam_openid_connect_provider.eks
  ]
}

# ---------- Kubernetes ServiceAccount ----------
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
    }
  }

  depends_on = [
    aws_eks_node_group.ng
  ]
}

# ---------- Helm Install ----------
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.8.0"

  wait    = true
  atomic  = true
  timeout = 900

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}
