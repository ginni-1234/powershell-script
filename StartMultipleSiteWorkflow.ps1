####Refer to: http://www.rapidcircle.com/powershell-start-a-workflow-for-all-items-a-list-on-sharepoint-online/

###Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll”
Add-Type -Path “C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll”

###Specify tenant admin and site URL
$SiteUrl = "https://XXX.sharepoint.com/sites/XXX"
$UserName = "user@XXX.onmicrosoft.com"
$SecurePassword = ConvertTo-SecureString "XXX" -AsPlainText -Force
$WorkflowName = "XXX"
$numberWorkflowsToStart = 2

###Connect to site collection
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
$clientContext.Credentials = $credentials

###Retrieve WorkflowService related objects
$WorkflowServicesManager = New-Object Microsoft.SharePoint.Client.WorkflowServices.WorkflowServicesManager($ClientContext, $ClientContext.Web)
$WorkflowSubscriptionService = $WorkflowServicesManager.GetWorkflowSubscriptionService()
$WorkflowInstanceService = $WorkflowServicesManager.GetWorkflowInstanceService()
$ClientContext.Load($WorkflowServicesManager)
$ClientContext.Load($WorkflowSubscriptionService)
$ClientContext.Load($WorkflowInstanceService)
$ClientContext.ExecuteQuery()

###Get WorkflowAssociations within Site
$WorkflowAssociations = $WorkflowSubscriptionService.EnumerateSubscriptions()
$ClientContext.Load($WorkflowAssociations)
$ClientContext.ExecuteQuery()

###List down all workflow id and name
foreach ($wf in $WorkflowAssociations) 
{ 
    if($wf.Name -eq $WorkflowName)
    {
        $WorkflowAssociation = $wf
        break
    }
}

###Prepare Start Workflow Payload
$Dict = New-Object 'System.Collections.Generic.Dictionary[System.String,System.Object]'

for($i=1; $i -le $numberWorkflowsToStart; $i++)
{
    $newItemSuffix = $i.ToString("00000")
    $msg = [string]::Format("Starting workflow {0} ({1})", $WorkflowAssociation.Name, $i)
    Write-Host $msg

    ###Start Site Workflow
    $Action = $WorkflowInstanceService.StartWorkflow($WorkflowAssociation, $Dict)
    $ClientContext.ExecuteQuery()
}
 
write-host "End"
