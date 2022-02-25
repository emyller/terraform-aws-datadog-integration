locals {
  # Collect all log-ready AWS services enabled in the DataDog account
  account_aws_log_ready_services = jsondecode(data.http.available_log_ready_services.body)[*].id
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
  services = setintersection(var.log_aws_services, local.account_aws_log_ready_services)
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
