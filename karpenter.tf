# Controller IAM role with Pod Identity association, node IAM role with access entry,
# SQS interruption queue and EventBridge rules (spot interruption, rebalance,
# instance state change, AWS Health scheduled changes) feeding it.
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.29.0"

  cluster_name = module.eks.cluster_name

  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = "${var.cluster_name}-karpenter-node"
  node_iam_role_attach_cni_policy = false
}

resource "helm_release" "karpenter_crd" {
  name       = "karpenter-crd"
  namespace  = module.karpenter.namespace
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter-crd"
  version    = "1.15.1"
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = module.karpenter.namespace
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.15.1"
  skip_crds  = true
  wait       = true

  values = [yamlencode({
    serviceAccount = {
      name = module.karpenter.service_account
    }
    nodeSelector = {
      "kubernetes.io/os" = "linux"
      role               = "system"
    }
    controller = {
      # IMDS hop limit is 1 on the system nodes, so the pod cannot look the region up.
      env = [{ name = "AWS_REGION", value = var.region }]
      resources = {
        requests = { cpu = "500m", memory = "512Mi" }
        limits   = { memory = "1Gi" }
      }
    }
    settings = {
      clusterName       = module.eks.cluster_name
      interruptionQueue = module.karpenter.queue_name
    }
  })]

  depends_on = [helm_release.karpenter_crd, module.karpenter, module.eks]
}

# NodePools and EC2NodeClass from k8s/karpenter. On destroy, Helm waits until Karpenter
# has drained and terminated its nodes, so the VPC can be deleted afterwards.
resource "helm_release" "karpenter_node_pools" {
  name      = "karpenter-node-pools"
  namespace = module.karpenter.namespace
  chart     = "${path.module}/k8s/karpenter"
  wait      = true
  timeout   = 1800

  values = [yamlencode({
    clusterName  = module.eks.cluster_name
    nodeRoleName = module.karpenter.node_iam_role_name
    tags         = local.tags
  })]

  depends_on = [helm_release.karpenter]
}
