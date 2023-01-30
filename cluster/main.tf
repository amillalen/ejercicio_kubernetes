resource "azurerm_resource_group" "rg-aks-environment"{
   name = var.rg_name
   location = var.rg_location

   tags = {
      "Grupo" = var.group
   }
}

resource "azurerm_virtual_network" "vnet-aks-environment" {
  name = "k8s-vnet"
  address_space = ["12.0.0.0/16"]
  location = azurerm_resource_group.rg-aks-environment.location
  resource_group_name = azurerm_resource_group.rg-aks-environment.name
}

resource "azurerm_subnet" "subnet-aks-environment" {
  name= "internal"
  resource_group_name = azurerm_resource_group.rg-aks-environment.name
  virtual_network_name = azurerm_virtual_network.vnet-aks-environment.name
  address_prefixes = ["12.0.0.0/20"]
  
}

resource "azurerm_container_registry" "acr-aks-environment" {
  name = "acrk8sg1"
  resource_group_name = azurerm_resource_group.rg-aks-environment.name
  location = azurerm_resource_group.rg-aks-environment.location
  sku = "Basic"
  admin_enabled = true
}



resource "azurerm_kubernetes_cluster" "aks-environment" {
  name = "aks-environment-g1"
  location = azurerm_resource_group.rg-aks-environment.location
  resource_group_name = azurerm_resource_group.rg-aks-environment.name
  dns_prefix = "aksg1"
  kubernetes_version = "1.24.6"
  
  default_node_pool {
     name = "default"
     node_count = 1 
     vm_size = "Standard_D2_V2"
     vnet_subnet_id = azurerm_subnet.subnet-aks-environment.id
     enable_auto_scaling = true
     max_count = 3
     min_count = 1
  }
  service_principal {
    client_id = "6e53bd1d-ff34-4f05-b969-f5bcb06be665"
    client_secret = var.client_secret
  }
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }
  role_based_access_control_enabled = true

}




