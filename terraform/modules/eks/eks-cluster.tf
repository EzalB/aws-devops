# Create EKS cluster role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
  tags = var.tags
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Attach standard managed policies for control plane
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSServicePolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Create cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(var.tags, { Name = var.cluster_name })
}

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks_cluster.name
}

# Optionally create OIDC provider for IRSA
resource "aws_iam_openid_connect_provider" "oidc" {
  count = var.eks_oidc_enabled ? 1 : 0

  url = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    # It's generally better to fetch thumbprint dynamically or provide as var. Using amazon's public CA thumbprint
    "9e99a48a9960b14926bb7f3b02e22da0afd33a8f"
  ]
}

# Node group IAM role
resource "aws_iam_role" "node_group_role" {
  count = length(var.node_groups) > 0 ? 1 : 0
  name  = "${var.cluster_name}-ng-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
  tags = var.tags
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  count      = length(var.node_groups) > 0 ? 1 : 0
  role       = aws_iam_role.node_group_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  count      = length(var.node_groups) > 0 ? 1 : 0
  role       = aws_iam_role.node_group_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  count      = length(var.node_groups) > 0 ? 1 : 0
  role       = aws_iam_role.node_group_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Managed node groups
resource "aws_eks_node_group" "managed" {
  for_each = { for ng in var.node_groups : ng.name => ng }

  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node_group_role[0].arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_capacity
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  instance_types = each.value.instance_types
  disk_size      = each.value.disk_size

  tags = merge(var.tags, each.value.tags, { Name = "${var.cluster_name}-${each.key}" })
}

# (Optional) Fargate profiles
resource "aws_eks_fargate_profile" "fargate" {
  for_each = { for fp in var.fargate_profiles : fp.name => fp }

  cluster_name = aws_eks_cluster.eks_cluster.name
  fargate_profile_name = each.key
  pod_execution_role_arn = each.value.pod_execution_role_arn
  subnet_ids = var.private_subnet_ids

  selector {
    for_each = toset([for s in each.value.selectors : s.namespace])
    namespace = each.value.selectors[0].namespace
  }
}
