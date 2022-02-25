# app-user

A Terraform module to integrate AWS to DataDog accounts.


## Usage example

It is mandatory to first set up the DataDog provider in your configuration.

```hcl
terraform {
  ...

  required_providers {
    ...
    datadog = {
      source  = "datadog/datadog"
      version = "~> 4.0"
    }
  }
}
```

Then set up the integration:

```hcl
module "datadog_aws_integration" {
  source = "emyller/datadog-integration/aws"
  version = "~> 1.0"

  name = "production"

  # Datadog keys
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key

  # Enable logs from CloudWatch
  cloudwatch_log_groups_prefix = "/aws/ecs/"
}
```
