resource "aws_iam_role" "sb_todo_app" {
  name = "sb-todo-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.default_tags, {
    Name = "sb-todo-app"
  })
}
