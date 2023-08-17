terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azapi" {
  skip_provider_registration = false
}

variable "resource_name" {
  type    = string
  default = "acctest0001"
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azapi_resource" "resourceGroup" {
  type                      = "Microsoft.Resources/resourceGroups@2020-06-01"
  name                      = var.resource_name
  location                  = var.location
}

resource "azapi_resource" "namespace" {
  type      = "Microsoft.ServiceBus/namespaces@2022-01-01-preview"
  parent_id = azapi_resource.resourceGroup.id
  name      = var.resource_name
  location  = var.location
  body = jsonencode({
    identity = {
      type                   = "None"
      userAssignedIdentities = null
    }
    properties = {
      disableLocalAuth    = false
      publicNetworkAccess = "Enabled"
      zoneRedundant       = false
    }
    sku = {
      capacity = 0
      name     = "Standard"
      tier     = "Standard"
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

resource "azapi_resource" "topic" {
  type      = "Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview"
  parent_id = azapi_resource.namespace.id
  name      = var.resource_name
  body = jsonencode({
    properties = {
      enableBatchedOperations    = false
      enableExpress              = false
      enablePartitioning         = false
      maxSizeInMegabytes         = 5120
      requiresDuplicateDetection = false
      status                     = "Active"
      supportOrdering            = false
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

resource "azapi_resource" "subscription" {
  type      = "Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-06-01-preview"
  parent_id = azapi_resource.topic.id
  name      = var.resource_name
  body = jsonencode({
    properties = {
      clientAffineProperties = {
      }
      deadLetteringOnFilterEvaluationExceptions = true
      deadLetteringOnMessageExpiration          = false
      enableBatchedOperations                   = false
      isClientAffine                            = false
      maxDeliveryCount                          = 10
      requiresSession                           = false
      status                                    = "Active"
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}
