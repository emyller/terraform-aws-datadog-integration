variable "name" {
  description = <<-EOT
    A name for the integration.
    Resources will be named with "datadog-$${var.name}".
  EOT
  type = string
}
