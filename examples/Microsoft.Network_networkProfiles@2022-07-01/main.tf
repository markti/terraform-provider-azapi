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

resource "azapi_resource" "virtualNetwork" {
  type      = "Microsoft.Network/virtualNetworks@2022-07-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = var.resource_name
  location  = var.location
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = [
          "10.1.0.0/16",
        ]
      }
      dhcpOptions = {
        dnsServers = [
        ]
      }
      subnets = [
      ]
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
  ignore_changes            = ["properties.subnets"]
}

resource "azapi_resource" "subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  parent_id = azapi_resource.virtualNetwork.id
  name      = var.resource_name
  body = jsonencode({
    properties = {
      addressPrefix = "10.1.0.0/24"
      delegations = [
        {
          name = "acctestdelegation-230630033653886950"
          properties = {
            serviceName = "Microsoft.ContainerInstance/containerGroups"
          }
        },
      ]
      privateEndpointNetworkPolicies    = "Enabled"
      privateLinkServiceNetworkPolicies = "Enabled"
      serviceEndpointPolicies = [
      ]
      serviceEndpoints = [
      ]
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

resource "azapi_resource" "networkProfile" {
  type      = "Microsoft.Network/networkProfiles@2022-07-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = var.resource_name
  location  = var.location
  body = jsonencode({
    properties = {
      containerNetworkInterfaceConfigurations = [
        {
          name = "acctesteth-230630033653886950"
          properties = {
            ipConfigurations = [
              {
                name = "acctestipconfig-230630033653886950"
                properties = {
                  subnet = {
                    id = azapi_resource.subnet.id
                  }
                }
              },
            ]
          }
        },
      ]
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}
