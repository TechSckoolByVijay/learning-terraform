resource "azurerm_resource_group" "rg" {
  name     = "${local.base_name}-RG"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.base_name}-VNet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "web" {
  name                 = "${local.base_name}-Web-Subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "${local.base_name}-DB-Subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_storage_account" "mysuperstorage" {
  name                          = "sainivijay97844"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.region
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}

resource "azurerm_storage_container" "data" {
  name = "raw-data"
  storage_account_id = azurerm_storage_account.mysuperstorage.id
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.mysuperstorage
  ]
}

