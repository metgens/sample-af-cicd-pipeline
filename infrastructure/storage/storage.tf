
resource "azurerm_storage_account" "app_storage" {
  name                     = "mefunctionsapptestsa"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
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

output "storage_account_name" {
  value = azurerm_storage_account.app_storage.name
}

output "storage_account_access_key" {
  value = azurerm_storage_account.app_storage.primary_access_key
}