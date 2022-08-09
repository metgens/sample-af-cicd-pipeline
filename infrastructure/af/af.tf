resource "azurerm_service_plan" "app_plan" {
  name                = "meazure-functions-test-service-plan"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "app_af" {
  name                       = "metest-azure-functions"
  location                   = var.resource_group_location
  resource_group_name        = var.resource_group_name
  service_plan_id        = azurerm_service_plan.app_plan.id
  storage_account_name       = azurerm_storage_account.app_storage.name
  storage_account_access_key = azurerm_storage_account.app_storage.primary_access_key
  site_config {}
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = var.archive_file_url,
  }
}