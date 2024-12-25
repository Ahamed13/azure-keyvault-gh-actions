terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.5.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }
}