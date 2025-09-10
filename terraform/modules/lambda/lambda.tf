
resource "aws_lambda_function" "lambda_func" {
  for_each = { for f in var.functions : f.name => f }

  function_name = "${var.name_prefix}-${each.key}"
  filename      = lookup(each.value, "filename", null)
  s3_bucket     = lookup(each.value, "s3_bucket", null)
  s3_key        = lookup(each.value, "s3_key", null)
  source_code_hash = lookup(each.value, "source_code_hash", null)
  handler       = each.value.handler
  runtime       = each.value.runtime
  memory_size   = each.value.memory
  timeout       = each.value.timeout
  role          = lookup(each.value, "role_arn", data.aws_iam_role.lambda_role.arn)

  environment {
    variables = each.value.env
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-${each.key}" })
}

# if role not provided, reference iam module role (data lookup)
data "aws_iam_role" "lambda_role" {
  # do not fail if role not exists; name requires that modules/iam created the role with expected name.
  name = "${var.name_prefix}-lambda-exec"
  # optional: ignore errors if not present in some setups (not supported directly), better pass role_arn
}
