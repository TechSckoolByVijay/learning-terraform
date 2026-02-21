resource "azurerm_resource_group" "hub" {
  name     = "${local.hub_name}-rg"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "${local.hub_name}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_address_space]
}


resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [local.hub_bastion_subnet]
}

resource "azurerm_subnet" "router" {
  name                 = "snet-router"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [local.hub_router_subnet]
}


resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${local.hub_name}-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}



resource "azurerm_network_interface" "hub_router_nic" {
  name                = "${local.hub_name}-router-nic"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.router.id
    private_ip_address_allocation = "Dynamic"
  }
  ip_forwarding_enabled = true
}

resource "azurerm_linux_virtual_machine" "router" {
  name                = "${local.hub_name}-router-vm"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  size                = "Standard_D2s_v3"

  network_interface_ids = [
    azurerm_network_interface.hub_router_nic.id,
  ]
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

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

//"echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p" 

resource "azurerm_virtual_machine_extension" "enable_routing" {
  name                 = "enable-routing"
  virtual_machine_id   = azurerm_linux_virtual_machine.router.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = jsonencode({
    "commandToExecute" = "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
  })
}