
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.6"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform"
    storage_account_name = "mystatefilesimp"
    container_name       = "tfstate"
    key                  = "capstone.terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # Service Principal Authentication Fields
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}