resource "azurerm_resource_group" "hub_rg" {
  name     = "rg-${local.hub_prefix}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-${local.hub_prefix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
}

resource "azurerm_subnet" "hub_router_snet" {
  name                 = "snet-hub-router"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "hub_router_nic" {
  name                  = "nic-${local.hub_prefix}-router"
  location              = azurerm_resource_group.hub_rg.location
  resource_group_name   = azurerm_resource_group.hub_rg.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_router_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.nva_ip
  }
}

resource "azurerm_linux_virtual_machine" "hub_router_vm" {
  name                            = "vm-${local.hub_prefix}-router"
  resource_group_name             = azurerm_resource_group.hub_rg.name
  location                        = azurerm_resource_group.hub_rg.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.hub_router_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "enable_routing" {
  name                 = "enable-routing"
  virtual_machine_id   = azurerm_linux_virtual_machine.hub_router_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = jsonencode({
    "commandToExecute" = "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
  })
}

# Shared Bastion for all environments
resource "azurerm_subnet" "bastion_snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "main_bastion" {
  name                = "bastion-shared-hub"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  ip_configuration {
    name                 = "cfg"
    subnet_id            = azurerm_subnet.bastion_snet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}