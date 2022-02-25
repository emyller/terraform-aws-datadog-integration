terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

data "aws_caller_identity" "main" {}  # AWS account info
