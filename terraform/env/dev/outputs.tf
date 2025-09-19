#output "vpc_id" {
#  description = "ID of the VPC"
#  value       = module.vpc.vpc_id
#}
#
#output "public_subnets" {
#  description = "Public subnet IDs"
#  value       = module.vpc.public_subnets
#}
#
#output "private_subnets" {
#  description = "Private subnet IDs"
#  value       = module.vpc.private_subnets
#}
#
#output "eks_cluster_name" {
#  description = "EKS cluster name"
#  value = module.eks.cluster_id
#}
#
#output "eks_cluster_endpoint" {
#  description = "EKS cluster endpoint"
#  value       = module.eks.cluster_endpoint
#}
#
#output "ecr_repo_urls" {
#  description = "ECR repositories"
#  value       = module.ecr.repo_urls
#}
#
#output "s3_bucket_names" {
#  description = "S3 bucket names"
#  value       = [for b in module.s3.buckets : b.name]
#}
#
#output "lambda_function_names" {
#  description = "Lambda function names"
#  value       = [for f in module.lambda.functions : f.name]
#}
