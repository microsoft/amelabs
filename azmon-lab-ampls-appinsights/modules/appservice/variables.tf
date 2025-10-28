variable "prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "plan_sku" {
  type    = string
  default = "S1"
}

# Names (optional)
variable "dotnet_app_name" {
  type    = string
  default = null
}

variable "java_app_name" {
  type    = string
  default = null
}

variable "node_app_name" {
  type    = string
  default = null
}

# Observability
variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "appinsights_connection_string" {
  type    = string
  default = null
}

# VNet Integration (required)
variable "integration_subnet_id" {
  type = string
}

# Runtimes
variable "dotnet_version" {
  type    = string
  default = "8.0"
}

variable "java_version" {
  type    = string
  default = "17"
}

variable "java_server" {
  type    = string
  default = "JAVA"   # Java SE
}

variable "java_server_version" {
  type    = string
  default = "17"
}

variable "java_app_command_line" {
  type        = string
  default     = "java -javaagent:/home/site/wwwroot/agent/applicationinsights-agent.jar -jar /home/site/wwwroot/app.jar"
  description = "Custom startup command for the Java Web App"
}

# Node.js configuration
variable "node_version" {
  type    = string
  default = "22-lts"
}

variable "node_app_command_line" {
  type        = string
  default     = "npm start"
  description = "Custom startup command for the Node.js Web App"
}


variable "tags" {
  type    = map(string)
  default = {}
}
