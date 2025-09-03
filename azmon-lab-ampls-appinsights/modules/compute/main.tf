# Compute Module - Windows & Ubuntu VMs with Azure Monitor Agent

# Generate random password for VMs
resource "random_password" "vm_password" {
  length  = 16
  special = true
}

# Public IP for Windows VM (for initial access)
resource "azurerm_public_ip" "windows_vm_pip" {
  count               = var.enable_public_ips ? 1 : 0
  name                = "${var.prefix}-windows-vm-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Public IP for Ubuntu VM (for initial access)
resource "azurerm_public_ip" "ubuntu_vm_pip" {
  count               = var.enable_public_ips ? 1 : 0
  name                = "${var.prefix}-ubuntu-vm-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Network Interface for Windows VM
resource "azurerm_network_interface" "windows_vm_nic" {
  name                = "${var.prefix}-windows-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.windows_vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ips ? azurerm_public_ip.windows_vm_pip[0].id : null
  }

  tags = var.tags
}

# Network Interface for Ubuntu VM
resource "azurerm_network_interface" "ubuntu_vm_nic" {
  name                = "${var.prefix}-ubuntu-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.ubuntu_vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ips ? azurerm_public_ip.ubuntu_vm_pip[0].id : null
  }

  tags = var.tags
}

# Windows Server VM
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                = "${var.prefix}-windows-vm"
  computer_name       = "winvm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password != null ? var.admin_password : random_password.vm_password.result

  network_interface_ids = [
    azurerm_network_interface.windows_vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.windows_vm_image.publisher
    offer     = var.windows_vm_image.offer
    sku       = var.windows_vm_image.sku
    version   = var.windows_vm_image.version
  }

  identity {
    type = "SystemAssigned"
  }

  # Install Azure Monitor Agent
  provision_vm_agent = true

  tags = var.tags
}

# Ubuntu Server VM
resource "azurerm_linux_virtual_machine" "ubuntu_vm" {
  name                = "${var.prefix}-ubuntu-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  disable_password_authentication = false
  admin_password                  = var.admin_password != null ? var.admin_password : random_password.vm_password.result

  network_interface_ids = [
    azurerm_network_interface.ubuntu_vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.ubuntu_vm_image.publisher
    offer     = var.ubuntu_vm_image.offer
    sku       = var.ubuntu_vm_image.sku
    version   = var.ubuntu_vm_image.version
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Azure Monitor Agent Extension for Windows VM
resource "azurerm_virtual_machine_extension" "azure_monitor_agent_windows" {
  name                 = "AzureMonitorWindowsAgent"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_windows_virtual_machine.windows_vm
  ]

  tags = var.tags
}

# Custom Script Extension for .NET Core App Deployment
resource "azurerm_virtual_machine_extension" "windows_vm_custom_script" {
  name                 = "InstallDotNetApp"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = [
      "https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-ampls-appinsights/scripts/install-dotnet-app-winvm.ps1?token=GHSAT0AAAAAADGPIW3WTWZWAVBPUSN7WOKQ2FYD7CA"
    ]
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File install-dotnet-app-winvm.ps1 -ConnectionString \"${var.application_insights_connection_string}\""
  })

  depends_on = [
    azurerm_virtual_machine_extension.azure_monitor_agent_windows
  ]

  tags = var.tags
}

# Azure Monitor Agent Extension for Ubuntu VM
resource "azurerm_virtual_machine_extension" "azure_monitor_agent_linux" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.ubuntu_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_linux_virtual_machine.ubuntu_vm
  ]

  tags = var.tags
}

# Custom Script Extension for Python and Flask App Deployment on Ubuntu VM
resource "azurerm_virtual_machine_extension" "ubuntu_vm_custom_script" {
  name                 = "InstallPythonAndFlaskApps"
  virtual_machine_id   = azurerm_linux_virtual_machine.ubuntu_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = jsonencode({
    fileUris = [
      "https://raw.githubusercontent.com/microsoft/amelabs/refs/heads/main/azmon-lab-ampls-appinsights/scripts/install-python-apps-linuxvm.sh?token=GHSAT0AAAAAADGPIW3WHPITMSFWW2EEKQ4W2FYD5TQ?t=${timestamp()}"
    ]
    commandToExecute = "bash install-python-apps-linuxvm.sh \"${var.application_insights_connection_string}\""
  })

  depends_on = [
    azurerm_virtual_machine_extension.azure_monitor_agent_linux
  ]

  tags = var.tags
}

# Reboot Ubuntu VM after custom script installation
resource "null_resource" "ubuntu_vm_reboot" {
  provisioner "local-exec" {
    command = "az vm run-command invoke --resource-group ${var.resource_group_name} --name ${var.prefix}-ubuntu-vm --command-id RunShellScript --scripts 'sudo reboot'"
  }

  depends_on = [
    azurerm_virtual_machine_extension.ubuntu_vm_custom_script
  ]
}

# Associate Data Collection Rule with Windows VM
resource "azurerm_monitor_data_collection_rule_association" "windows_vm" {
  name                    = "${var.prefix}-dcra-windows"
  target_resource_id      = azurerm_windows_virtual_machine.windows_vm.id
  data_collection_rule_id = var.data_collection_rule_id
  
  depends_on = [
    azurerm_windows_virtual_machine.windows_vm,
    azurerm_virtual_machine_extension.azure_monitor_agent_windows
  ]
}

# Associate Data Collection Rule with Ubuntu VM
resource "azurerm_monitor_data_collection_rule_association" "ubuntu_vm" {
  name                    = "${var.prefix}-dcra-ubuntu"
  target_resource_id      = azurerm_linux_virtual_machine.ubuntu_vm.id
  data_collection_rule_id = var.ubuntu_data_collection_rule_id
  
  depends_on = [
    azurerm_linux_virtual_machine.ubuntu_vm,
    azurerm_virtual_machine_extension.azure_monitor_agent_linux
  ]
}

# Associate Data Collection Endpoint with Windows VM
resource "azurerm_monitor_data_collection_rule_association" "windows_vm_dce" {
  name                        = "configurationAccessEndpoint"
  target_resource_id          = azurerm_windows_virtual_machine.windows_vm.id
  data_collection_endpoint_id = var.data_collection_endpoint_id
  
  depends_on = [
    azurerm_windows_virtual_machine.windows_vm,
    azurerm_virtual_machine_extension.azure_monitor_agent_windows
  ]
}

# Associate Data Collection Endpoint with Ubuntu VM
resource "azurerm_monitor_data_collection_rule_association" "ubuntu_vm_dce" {
  name                        = "configurationAccessEndpoint"
  target_resource_id          = azurerm_linux_virtual_machine.ubuntu_vm.id
  data_collection_endpoint_id = var.data_collection_endpoint_id
  
  depends_on = [
    azurerm_linux_virtual_machine.ubuntu_vm,
    azurerm_virtual_machine_extension.azure_monitor_agent_linux
  ]
}

# Auto-shutdown for Windows VM
resource "azurerm_dev_test_global_vm_shutdown_schedule" "windows_vm_shutdown" {
  count              = var.enable_autoshutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.windows_vm.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.autoshutdown_time
  timezone              = var.autoshutdown_timezone

  notification_settings {
    enabled         = var.autoshutdown_notification_enabled
    time_in_minutes = var.autoshutdown_notification_time_minutes
    email           = var.autoshutdown_notification_email
  }

  tags = var.tags
}

# Auto-shutdown for Ubuntu VM
resource "azurerm_dev_test_global_vm_shutdown_schedule" "ubuntu_vm_shutdown" {
  count              = var.enable_autoshutdown ? 1 : 0
  virtual_machine_id = azurerm_linux_virtual_machine.ubuntu_vm.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.autoshutdown_time
  timezone              = var.autoshutdown_timezone

  notification_settings {
    enabled         = var.autoshutdown_notification_enabled
    time_in_minutes = var.autoshutdown_notification_time_minutes
    email           = var.autoshutdown_notification_email
  }

  tags = var.tags
}
