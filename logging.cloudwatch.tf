locals {
  # Map all known CloudWatch log groups
  log_groups = {
    for name in try(data.aws_cloudwatch_log_groups.all[0].log_group_names, []):
    (name) => data.aws_cloudwatch_log_group.all[name].arn
    if name != "/aws/lambda/datadog-forwarder"  # Prevent infinite loops
  }
}

data "aws_cloudwatch_log_groups" "all" {
  /*
  Fetch a list of all existing log groups in CloudWatch

  If a prefix isn't given, use a random string that never matches any groups.
  */
  count = var.cloudwatch_log_groups_prefix != null ? 1 : 0
  log_group_name_prefix = var.cloudwatch_log_groups_prefix
}

data "aws_cloudwatch_log_group" "all" {
  /*
  Fetch details about every log group in CloudWatch
  */
  for_each = try(data.aws_cloudwatch_log_groups.all[0].log_group_names, {})
  name = each.key
}

resource "aws_cloudwatch_log_subscription_filter" "forwarder" {
  for_each = local.log_groups
  name = "datadog"
  log_group_name = each.key
  filter_pattern = ""
  destination_arn = data.aws_lambda_function.forwarder.arn
}

resource "aws_lambda_permission" "forwarder" {
  for_each = local.log_groups
  statement_id = "datadog-${replace(each.key, "/\\W/", "-")}"
  action = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.forwarder.arn
  principal = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn = "${each.value}:*"
}
