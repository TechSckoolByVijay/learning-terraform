terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.5"
    }
  }
  # Note: Add your backend {} block here if using a Remote Storage Account
}

provider "azurerm" {
  features {}
  subscription_id = "db8fcd00-4f68-42c3-8b19-947bf4d7b2c5"
}

