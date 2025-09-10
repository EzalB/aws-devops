resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repos)

  name                 = "${var.name_prefix}-${each.key}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-${each.key}" })
}
