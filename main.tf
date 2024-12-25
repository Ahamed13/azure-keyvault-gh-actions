data "azurerm_client_config" "current" {} 

resource "azurerm_resource_group" "rgp" {
  name = var.resource_group_name
  location = var.location
}
resource "azurerm_key_vault" "key-vault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rgp.location
  resource_group_name         = azurerm_resource_group.rgp.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = var.key_vault_sku_name
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true

  depends_on = [ azurerm_resource_group.rgp, data.azurerm_client_config.current ]
}

resource "azurerm_key_vault_access_policy" "user" {
  key_vault_id = azurerm_key_vault.key-vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "GetRotationPolicy",
  ]

  depends_on = [ azurerm_key_vault.key-vault ]
}

resource "azurerm_key_vault_key" "encrypt-key" {
  name         = var.key_vault_key_name
  key_vault_id = azurerm_key_vault.key-vault.id
  key_type     = "RSA"
  key_size     = 4096

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_disk_encryption_set" "disk_encryption_set" {
  name                = var.disk_encryption_set_name
  resource_group_name = azurerm_resource_group.rgp.name
  location            = azurerm_resource_group.rgp.location
  key_vault_key_id    = azurerm_key_vault_key.encrypt-key.id

  identity {
    type = "SystemAssigned"
  }

  depends_on = [ azurerm_key_vault_key.encrypt-key ]
}

resource "azurerm_key_vault_access_policy" "disk-encrypt-policy" {
  key_vault_id = azurerm_key_vault.key-vault.id

  tenant_id = azurerm_disk_encryption_set.disk_encryption_set.identity[0].tenant_id
  object_id = azurerm_disk_encryption_set.disk_encryption_set.identity[0].principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "UnwrapKey",
    "WrapKey",
    "Encrypt",
  ]
  depends_on = [ azurerm_disk_encryption_set.disk_encryption_set ]
}

resource "azurerm_role_assignment" "disk_encrypt_role" {
  scope                = azurerm_key_vault.key-vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.disk_encryption_set.identity[0].principal_id

  depends_on = [ azurerm_disk_encryption_set.disk_encryption_set, azurerm_key_vault_access_policy.disk-encrypt-policy ]
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = var.data_disk_name
  location             = azurerm_resource_group.rgp.location
  resource_group_name  = azurerm_resource_group.rgp.name
  storage_account_type = var.data_disk_storage_type
  create_option        = var.data_disk_creation_option
  disk_size_gb         = var.data_disk_size_gb
  disk_encryption_set_id = azurerm_disk_encryption_set.disk_encryption_set.id

  depends_on = [ azurerm_disk_encryption_set.disk_encryption_set ]
}