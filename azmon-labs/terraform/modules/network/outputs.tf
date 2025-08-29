output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.bap.id
}
