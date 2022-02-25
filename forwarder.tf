module "api_key_secret" {
  source = "emyller/secret/aws"
  version = "~> 1.0"
  name = "/${var.name}/DATADOG_API_KEY"
  contents = var.api_key
}

resource "aws_cloudformation_stack" "forwarder" {
  /*
  Datadog Forwarder to ship logs from S3 and CloudWatch

  https://docs.datadoghq.com/serverless/libraries_integrations/forwarder/
  */
  name = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters = {
    DdApiKeySecretArn = module.api_key_secret.arn
    DdSite = "datadoghq.com"
    FunctionName = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}

data "aws_lambda_function" "forwarder" {
  /*
  Fetch information about the Lambda function created by aws_cloudformation_stack.forwarder
  */
  function_name = "datadog-forwarder"
  depends_on = [aws_cloudformation_stack.forwarder]
}

resource "datadog_integration_aws_lambda_arn" "collector" {
  /*
  Set up a collector integration in DataDog
  */
  account_id = data.aws_caller_identity.main.account_id
  lambda_arn = data.aws_lambda_function.forwarder.arn
}

resource "datadog_integration_aws_log_collection" "main" {
  /*
  Register AWS services to the log collector
  */
  account_id = data.aws_caller_identity.main.account_id
  services = [for item in jsondecode(data.http.available_log_ready_services.body): item.id]
}

data "http" "available_log_ready_services" {
  /*
  Fetch list of available AWS services to collect logs from
  https://docs.datadoghq.com/api/latest/aws-logs-integration/#get-list-of-aws-log-ready-services
  */
  url = "https://api.datadoghq.com/api/v1/integration/aws/logs/services"
  request_headers = {
    "Content-Type" = "application/json"
    "DD-API-KEY" = var.api_key
    "DD-APPLICATION-KEY" = var.app_key
  }
}
