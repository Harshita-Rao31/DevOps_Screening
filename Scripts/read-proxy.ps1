function Get-BillingRecord {
    param (
        [string]$id,
        [string]$partitionKey
    )

    try {
        $record = az cosmosdb sql container item show `
          --account-name $env:CosmosAccount `
          --resource-group $env:ResourceGroup `
          --database-name $env:CosmosDbName `
          --container-name $env:CosmosContainer `
          --partition-key "$partitionKey" `
          --id "$id" | ConvertFrom-Json
        return $record
    } catch {
        # Read from Blob Storage
        $blobName = "$id.json"
        $blob = Get-AzStorageBlobContent -Blob $blobName `
          -Container $env:BlobContainer `
          -Context $storageContext `
          -Destination "$env:TEMP/$blobName" -Force
        $json = Get-Content "$env:TEMP/$blobName" -Raw | ConvertFrom-Json
        return $json
    }
}