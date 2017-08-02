###Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

###Specify tenant admin and site URL
$SiteUrl = "https://XXX.sharepoint.com/SiteName/"
$ListName = "List Name"
$UserName = "XXX@XXX.onmicrosoft.com"
$SecurePassword = ConvertTo-SecureString "XXX" -AsPlainText -Force

###Define variable
$numberItemsToCreate = 100
$itemNamePrefix = "Item1_"
$batchSize = 40

###Connect to site collection
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$clientContext.Credentials = $credentials


###Connect to List
$list = $clientContext.get_web().get_lists().getByTitle($ListName);
$clientContext.Load($list)
$clientContext.ExecuteQuery()

###Loop batch creation
for($j=1; $j -le $batchSize; $j++)
{
    $preffix = $j.ToString() + "_"

    for($i=1; $i -le $numberItemsToCreate; $i++)
    {
        $newItemSuffix = $i.ToString("00000")
        $ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
        $newItem = $list.AddItem($ListItemInfo)
        $newItem["Title"] = $preffix+$itemNamePrefix+$newItemSuffix
        $newItem.Update()
        $clientContext.Load($newItem)
        write-host "Item created: $preffix$itemNamePrefix$newItemSuffix"
    }

    $clientContext.ExecuteQuery()
    write-host "Sleeping 1 second"
    Start-Sleep -s 1
}

 
Write-Host "Finished!" -ForegroundColor Green

