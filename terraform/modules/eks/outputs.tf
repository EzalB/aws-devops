#output "cluster_id" {
#  value = aws_eks_cluster.eks_cluster.name
#}
#
#output "cluster_endpoint" {
#  value = aws_eks_cluster.eks_cluster.endpoint
#}
#
#output "cluster_certificate_authority" {
#  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
#}
#
#output "oidc_issuer" {
#  value = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
#  condition = length(aws_eks_cluster.eks_cluster.identity) > 0
#}
#
#output "node_group_names" {
#  value = try([for ng in aws_eks_node_group.managed : ng.node_group_name], [])
#}
