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
