Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Install-Module Az.StackHCI

Invoke-Command -ComputerName AZSHCINODE01 -ScriptBlock {
    Get-AzureStackHCI
}

$azshciNodeCreds = Get-Credential -UserName "hybrid\azureuser" -Message "Enter the hybrid\azureuser password"
Register-AzStackHCI `
    -SubscriptionId "your-subscription-ID-here" `
    -ResourceName "azshciclus" `
    -ResourceGroupName "AZSHCICLUS_RG" `
    -Region "EastUS" `
    -EnvironmentName "AzureCloud" `
    -ComputerName "AZSHCINODE01.hybrid.local" `
    -Credential $azshciNodeCreds
