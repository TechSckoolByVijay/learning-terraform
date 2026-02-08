resource "azurerm_resource_group" "prod_rg" {
  name     = "rg-${local.prod_prefix}"
  location = var.location
}

resource "azurerm_virtual_network" "prod_vnet" {
  name                = "vnet-${local.prod_prefix}"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
}

resource "azurerm_subnet" "prod_workload_snet" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  name                      = "peer-prod-to-hub"
  resource_group_name       = azurerm_resource_group.prod_rg.name
  virtual_network_name      = azurerm_virtual_network.prod_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "hub_to_prod" {
  name                      = "peer-hub-to-prod"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.prod_vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_network_interface" "prod_nic" {
  name                = "nic-${local.prod_prefix}-vm"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prod_workload_snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "prod_vm" {
  name                            = "vm-${local.prod_prefix}-workload"
  resource_group_name             = azurerm_resource_group.prod_rg.name
  location                        = azurerm_resource_group.prod_rg.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.prod_nic.id]
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

resource "azurerm_route_table" "prod_rt" {
  name                = "rt-${local.prod_prefix}"
  location            = azurerm_resource_group.prod_rg.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  route {
    name                   = "to-hub-nva"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = local.nva_ip
  }
}

resource "azurerm_subnet_route_table_association" "prod_rt_assoc" {
  subnet_id      = azurerm_subnet.prod_workload_snet.id
  route_table_id = azurerm_route_table.prod_rt.id
}