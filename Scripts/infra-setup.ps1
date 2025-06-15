$resourceGroup = "BillingSystemRG"
$storageAccount = "billingstorage123"
$containerName = "archived-billing"
$cosmosAccount = "billing-cosmos-db"
$cosmosDbName = "BillingDB"
$cosmosContainer = "BillingRecords"

az group create --name $resourceGroup --location eastus

az storage account create --name $storageAccount --resource-group $resourceGroup --sku Standard_GRS

az storage container create --account-name $storageAccount --name $containerName --auth-mode login

az cosmosdb create --name $cosmosAccount --resource-group $resourceGroup --locations regionName=eastus failoverPriority=0

az cosmosdb sql database create --account-name $cosmosAccount --name $cosmosDbName --resource-group $resourceGroup

az cosmosdb sql container create --account-name $cosmosAccount --database-name $cosmosDbName `
  --name $cosmosContainer --partition-key-path "/partitionKey" --resource-group $resourceGroup