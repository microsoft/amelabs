# Application Insights Module

# Application Insights Instance
resource "azurerm_application_insights" "main" {
  name                = "${var.prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.log_analytics_workspace_id
  application_type    = "web"
  
  # Connect to the same Log Analytics Workspace
  sampling_percentage = 100

  tags = var.tags
}
