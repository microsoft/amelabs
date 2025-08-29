# Data Collection Rule for VM Insights with Processes and Dependencies
resource "azurerm_monitor_data_collection_rule" "vm_insights" {
  name                = "MSVMI-${var.workspace_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Data Collection Rule for VM Insights with dependency agent"

  destinations {
    log_analytics {
      workspace_resource_id = var.workspace_id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-ServiceMap"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_sources {
    performance_counter {
      name                          = "VMInsightsPerfCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
    }

    # Extension for dependency mapping
    extension {
      streams        = ["Microsoft-ServiceMap"]
      extension_name = "DependencyAgent"
      name           = "DependencyAgentDataSource"
    }
  }

  tags = var.tags
}

# User Assigned Managed Identity for VM Insights (required by Install-VMInsights.ps1)
resource "azurerm_user_assigned_identity" "vm_insights" {
  name                = "${var.workspace_name}-vm-insights-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags
}

# Role assignment for the managed identity
resource "azurerm_role_assignment" "monitoring_metrics_publisher" {
  scope                = var.workspace_id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_user_assigned_identity.vm_insights.principal_id
}

# Use local-exec provisioner to run the official Install-VMInsights.ps1 script for Windows VM
resource "null_resource" "windows_vm_insights" {
  count = var.windows_vm_name != null && var.windows_vm_name != "" ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      pwsh -NoProfile -ExecutionPolicy Bypass -File "${path.module}/scripts/Install-VMInsights.ps1" `
        -SubscriptionId ${var.subscription_id} `
        -ResourceGroup ${var.resource_group_name} `
        -Name ${var.windows_vm_name} `
        -DcrResourceId ${azurerm_monitor_data_collection_rule.vm_insights.id} `
        -UserAssignedManagedIdentityResourceGroup ${var.resource_group_name} `
        -UserAssignedManagedIdentityName ${azurerm_user_assigned_identity.vm_insights.name} `
        -ProcessAndDependencies `
        -Approve
    EOT

    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    azurerm_monitor_data_collection_rule.vm_insights,
    azurerm_user_assigned_identity.vm_insights,
    azurerm_role_assignment.monitoring_metrics_publisher
  ]

  triggers = {
    dcr_id = azurerm_monitor_data_collection_rule.vm_insights.id
    uami_id = azurerm_user_assigned_identity.vm_insights.id
    script_hash = filesha256("${path.module}/scripts/Install-VMInsights.ps1")
  }
}

# Use local-exec provisioner to run the official Install-VMInsights.ps1 script for RedHat VM
resource "null_resource" "redhat_vm_insights" {
  count = var.redhat_vm_name != null && var.redhat_vm_name != "" ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      pwsh -NoProfile -ExecutionPolicy Bypass -File "${path.module}/scripts/Install-VMInsights.ps1" `
        -SubscriptionId ${var.subscription_id} `
        -ResourceGroup ${var.resource_group_name} `
        -Name ${var.redhat_vm_name} `
        -DcrResourceId ${azurerm_monitor_data_collection_rule.vm_insights.id} `
        -UserAssignedManagedIdentityResourceGroup ${var.resource_group_name} `
        -UserAssignedManagedIdentityName ${azurerm_user_assigned_identity.vm_insights.name} `
        -ProcessAndDependencies `
        -Approve
    EOT

    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    azurerm_monitor_data_collection_rule.vm_insights,
    azurerm_user_assigned_identity.vm_insights,
    azurerm_role_assignment.monitoring_metrics_publisher
  ]

  triggers = {
    dcr_id = azurerm_monitor_data_collection_rule.vm_insights.id
    uami_id = azurerm_user_assigned_identity.vm_insights.id
    script_hash = filesha256("${path.module}/scripts/Install-VMInsights.ps1")
  }
}
