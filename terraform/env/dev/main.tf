locals {
  name_prefix = "${var.environment}"
}

#module "vpc" {
#  source                = "../../modules/vpc"
#  name                  = "${local.name_prefix}-vpc"
#  cidr_block            = var.vpc_cidr_block
#  azs                   = var.vpc_azs
#  public_subnet_cidrs   = var.vpc_public_subnet_cidrs
#  private_subnet_cidrs  = var.vpc_private_subnet_cidrs
#  enable_nat_gateway    = var.vpc_enable_nat_gateway
#  tags                  = merge(var.default_tags, { Name = "${local.name_prefix}-vpc" })
#}

module "ecr" {
  source      = "../../modules/ecr"
  name_prefix = local.name_prefix
  repos       = var.ecr_repos
  tags        = var.default_tags
}

module "s3" {
  source      = "../../modules/s3"
  name_prefix = local.name_prefix
  buckets     = var.s3_buckets
  tags        = var.default_tags
}

#module "eks" {
#  source              = "../../modules/eks"
#  cluster_name        = "${local.name_prefix}-eks"
#  cluster_version     = var.eks_cluster_version
#  vpc_id              = module.vpc.vpc_id
#  public_subnet_ids   = module.vpc.public_subnets
#  private_subnet_ids  = module.vpc.private_subnets
#  node_groups         = var.eks_node_groups
#  fargate_profiles    = var.eks_fargate_profiles
#  tags                = var.default_tags
#  eks_oidc_enabled    = var.eks_oidc_enabled
#}
#
#module "lambda" {
#  source        = "../../modules/lambda"
#  name_prefix   = local.name_prefix
#  lambda_count  = length(var.lambda_functions)
#  functions     = var.lambda_functions
#  tags          = var.default_tags
#}
