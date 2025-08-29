# dcr/outputs.tf
output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.dcr_vmss.id
}