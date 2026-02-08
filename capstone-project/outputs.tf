output "hub_router_private_ip" {
  value = azurerm_network_interface.hub_router_nic.private_ip_address
}

output "dev_vm_private_ip" {
  value = azurerm_network_interface.dev_nic.private_ip_address
}

output "prod_vm_private_ip" {
  value = azurerm_network_interface.prod_nic.private_ip_address
}