provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "app_rgp" {
  name     = "meazure-functions-test-rg"
  location = "West Europe"
}

module "data" {
  source = "./storage"
  resource_group_location = azurerm_resource_group.app_rgp.location
  resource_group_name = azurerm_resource_group.app_rgp.name
}

module "af" {
  source = "./af"
  resource_group_location = azurerm_resource_group.app_rgp.location
  resource_group_name = azurerm_resource_group.app_rgp.name
  archive_file_url = module.data.archive_file_url
  storage_account_name = module.data.storage_account_name
  storage_account_access_key = module.data.storage_account_access_key
}
