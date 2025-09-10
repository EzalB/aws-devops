resource "aws_iam_policy" "sb_todo_app_policy" {
  name        = "sb-todo-app-policy"
  description = "Policy for sb-todo-app to access S3 and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetObject"]
        Resource = ["arn:aws:s3:::my-todo-app-bucket", "arn:aws:s3:::my-todo-app-bucket/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}
