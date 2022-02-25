variable "name" {
  description = <<-EOT
    A name for the integration.
    Resources will be named with "datadog-$${var.name}".
  EOT
  type = string
}

variable "api_key" {
  description = "The DataDog API key for the account."
  type = string
  sensitive = true
}

variable "app_key" {
  description = "The DataDog app key for the account."
  type = string
  sensitive = true
}

variable "log_aws_services" {
  description = "AWS services to log. This must match the DataDog account enabled services."
  type = list(string)
  default = []
}

variable "cloudwatch_log_groups_prefix" {
  description = "If set, will forward logs from log groups named with this prefix."
  type = string
  default = null
}
