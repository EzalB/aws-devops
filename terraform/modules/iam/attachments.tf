resource "aws_iam_role_policy_attachment" "sb_todo_app_attach" {
  role       = aws_iam_role.sb_todo_app.name
  policy_arn = aws_iam_policy.sb_todo_app_policy.arn
}
