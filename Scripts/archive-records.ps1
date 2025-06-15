param (
    [string]$CosmosConnString,
    [string]$Database,
    [string]$Container,
    [string]$StorageAccount,
    [string]$BlobContainer
)

# Date 3 months ago
$cutoffDate = (Get-Date).AddMonths(-3).ToString("o")
$query = "SELECT * FROM c WHERE c.timestamp < '$cutoffDate'"

# Query Cosmos DB for old records (example only)
$records = az cosmosdb sql query --account-name $env:CosmosAccount `
  --resource-group $env:ResourceGroup `
  --database-name $Database `
  --container-name $Container `
  --query-text "$query" | ConvertFrom-Json

$storageKey = az storage account keys list --account-name $StorageAccount `
  --query "[0].value" -o tsv
$storageContext = New-AzStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $storageKey

foreach ($record in $records) {
    $id = $record.id
    $json = $record | ConvertTo-Json -Depth 10
    $blobName = "$id.json"

    # Upload to Blob Storage
    Set-AzStorageBlobContent -Container $BlobContainer -Blob $blobName `
      -Content $json -Context $storageContext -Force

    # Delete from Cosmos DB
    az cosmosdb sql container item delete `
      --account-name $env:CosmosAccount `
      --resource-group $env:ResourceGroup `
      --database-name $Database `
      --container-name $Container `
      --partition-key "$record.partitionKey" `
      --id "$id"
}