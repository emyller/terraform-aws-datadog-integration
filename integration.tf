resource "datadog_integration_aws" "main" {
  account_id = data.aws_caller_identity.main.account_id
  role_name = local.iam_role_name
}
