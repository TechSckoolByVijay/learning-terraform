resource "azurerm_resource_group" "rg" {
  name     = "${local.base_name}-RG"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.base_name}-VNet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.vnet_space
}


resource "azurerm_subnet" "snet" {
  for_each = var.subnet_names

  name                 = "snet-${each.key}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [each.value] 
}


# resource "azurerm_subnet" "web" {
#   name                 = "${local.base_name}-Web-Subnet"
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   resource_group_name  = azurerm_resource_group.rg.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "db" {
#   name                 = "${local.base_name}-DB-Subnet"
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   resource_group_name  = azurerm_resource_group.rg.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

resource "azurerm_storage_account" "mysuperstorage" {
  #count = 3
  for_each = toset(var.dept_names)

  name                          = "myorg007vimp${each.value}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.region
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = var.is_public
}

resource "azurerm_storage_container" "data" {
  for_each = toset(var.dept_names)

  name = var.container_name
  storage_account_id = azurerm_storage_account.mysuperstorage[each.value].id
  container_access_type = "private"

  depends_on = [
    azurerm_storage_account.mysuperstorage
  ]
}

