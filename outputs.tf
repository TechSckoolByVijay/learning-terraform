output "primary_connection_string" {
  value = azurerm_storage_account.mysuperstorage.primary_connection_string
  sensitive=true
}

output "vnet_address_space" {
  value = azurerm_virtual_network.vnet.address_space
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}