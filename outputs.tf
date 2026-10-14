output "region" {
  description = "AWS region."
  value       = var.region
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "karpenter_interruption_queue" {
  description = "SQS queue Karpenter reads interruption events from."
  value       = module.karpenter.queue_name
}

output "karpenter_node_role_name" {
  description = "IAM role of nodes launched by Karpenter."
  value       = module.karpenter.node_iam_role_name
}

output "configure_kubectl" {
  description = "Writes a kubeconfig for this cluster to ./kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name} --kubeconfig ./kubeconfig"
}
