variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name. Also used as the karpenter.sh/discovery tag value."
  type        = string
  default     = "eks-karpenter-spot"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.37"
}

variable "vpc_cidr" {
  description = "VPC CIDR block. Split into three /19 private and three /24 public subnets."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint, e.g. your office or VPN egress IP as /32. No default: an API open to the internet should be a conscious choice."
  type        = list(string)
}

variable "system_node_instance_types" {
  description = "Instance types of the managed node group that runs cluster controllers (Graviton)."
  type        = list(string)
  default     = ["t4g.medium"]
}

variable "project" {
  description = "Value of the Project cost allocation tag."
  type        = string
  default     = "eks-karpenter-spot"
}

variable "environment" {
  description = "Value of the Environment cost allocation tag."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Value of the Owner cost allocation tag."
  type        = string
  default     = "QwertyUser17"
}
