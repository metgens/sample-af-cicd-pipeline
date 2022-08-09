data "archive_file" "app_archive" {
  type        = "zip"
  source_dir  = "../src/me.SampleAF/bin/Release/net6.0/publish"
  output_path = "artifacts/function-app.zip"
}

output "archive_file_url" {
	value = "https://${azurerm_storage_account.app_storage.name}.blob.core.windows.net/${azurerm_storage_container.app_storage_container.name}/${azurerm_storage_blob.app_storage_blob.name}${data.azurerm_storage_account_blob_container_sas.app_blob_sas.sas}"
}