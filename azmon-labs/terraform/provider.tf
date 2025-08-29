provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "random" {
  # No configuration needed
}
