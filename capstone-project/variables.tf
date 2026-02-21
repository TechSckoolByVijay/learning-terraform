variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure SPN App ID"
}

variable "client_secret" {
  type        = string
  description = "Azure SPN Client Secret"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "hub_address_space" { type = string }
variable "dev_address_space" { type = string }
variable "prod_address_space" { type = string }

variable "admin_username" { type = string }
variable "admin_password" { type = string }
 