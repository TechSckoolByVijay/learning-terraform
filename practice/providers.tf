
terraform {
  backend "azurerm" {
    resource_group_name = "terraform"
    storage_account_name = "mystatefilesimp"                              # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"                               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "dev.terraform.tfstate"                # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }
}


provider "azurerm" {
  features {}
  subscription_id = "db8fcd00-4f68-42c3-8b19-947bf4d7b2c5"
}