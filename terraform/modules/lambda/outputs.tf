output "lambda_arns" {
  value = { for k, l in aws_lambda_function.lambda_func : k => l.arn }
}
