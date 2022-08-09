provider "azurerm" {
  features {}
}

data "archive_file" "app_archive" {
  type        = "zip"
  source_dir  = "../src/me.SampleAF/bin/Release/net6.0/publish"
  output_path = "function-app.zip"
}

resource "azurerm_resource_group" "app_rgp" {
  name     = "meazure-functions-test-rg"
  location = "West Europe"
}

resource "azurerm_storage_account" "app_storage" {
  name                     = "mefunctionsapptestsa"
  resource_group_name      = azurerm_resource_group.app_rgp.name
  location                 = azurerm_resource_group.app_rgp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "app_storage_container" {
  name                  = "functions"
  storage_account_name  = azurerm_storage_account.app_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "app_storage_blob" {
  name = "${filesha256(data.archive_file.app_archive.output_path)}.zip"
  storage_account_name = azurerm_storage_account.app_storage.name
  storage_container_name = azurerm_storage_container.app_storage_container.name
  type = "Block"
  source = data.archive_file.app_archive.output_path
}

data "azurerm_storage_account_blob_container_sas" "app_blob_sas" {
  connection_string = azurerm_storage_account.app_storage.primary_connection_string
  container_name    = azurerm_storage_container.app_storage_container.name

  start = "2021-01-01T00:00:00Z"
  expiry = "2023-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

resource "azurerm_service_plan" "app_plan" {
  name                = "meazure-functions-test-service-plan"
  location            = azurerm_resource_group.app_rgp.location
  resource_group_name = azurerm_resource_group.app_rgp.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "app_af" {
  name                       = "metest-azure-functions"
  location                   = azurerm_resource_group.app_rgp.location
  resource_group_name        = azurerm_resource_group.app_rgp.name
  service_plan_id        = azurerm_service_plan.app_plan.id
  storage_account_name       = azurerm_storage_account.app_storage.name
  storage_account_access_key = azurerm_storage_account.app_storage.primary_access_key
  site_config {}
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.app_storage.name}.blob.core.windows.net/${azurerm_storage_container.app_storage_container.name}/${azurerm_storage_blob.app_storage_blob.name}${data.azurerm_storage_account_blob_container_sas.app_blob_sas.sas}",
  }
}