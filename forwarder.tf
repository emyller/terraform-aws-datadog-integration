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
