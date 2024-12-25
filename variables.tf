variable "location" {
    type = string
    default = "East Europe"
}
variable "resource_group_name" {
    type = string
    default = "rgp-tf"
}
variable "key_vault_name" {
    type = string
    default = "keyvault200200tf"
}
variable "key_vault_sku_name" {
    type = string
    default = "premium"

}
variable "key_vault_key_name" {
    type = string
    default = "encryptkey200200tf"
}
variable "disk_encryption_set_name" {
    type = string
    default = "diskencryptionset200200tf"    
}
variable "data_disk_name" {
    type = string
    default = "datadisk200200tf"
}
variable "data_disk_size_gb" {
    type = number
    default = 8
}
variable "data_disk_storage_type" {
    type = string
    default = "Standard_LRS"
}
variable "data_disk_creation_option" {
    type = string
    default = "Empty"
}
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
