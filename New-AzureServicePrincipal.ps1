Function New-AzureServicePrincipal {
   <#
      .Synopsis
         Create a new Service Principal to manage Azure resources.
      .Example
         New-AzureServicePrincipal -Name AutomationWorker
         Create a new Service Principal named AutomationWorker that can create and manage all types of Azure resources but can't grant access to others.
      .Example
         New-AzureServicePrincipal -Name AutomationWorker2 -Role Reader
         Create a new Service Principal named AutomationWorker2 that can view existing Azure resources.
   #>

   [CmdletBinding()]
   param (
      [string] $Name = "AutomationWorker",
      [string] $Role = "Contributor"
   )

   $AzContext = Get-AzContext

   If ($null -eq $AzContext) {
      Write-Verbose "No Azure context found, Sign in Azure required."
      Connect-AzAccount
   }

   $ServicePrincipal = New-AzADServicePrincipal -DisplayName $Name -Role $Role
   $ApplicationId = $ServicePrincipal.ApplicationId

   $TenantId = (Get-AzContext).Tenant.Id

   # Export the newly created service principal secret for future use (note that
   # the exported secret is in plain text therefore store it safely).
   $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ServicePrincipal.Secret)
   $UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

   $properties = @{
      Name = $Name
      Role = $Role
      ApplicationId = $ApplicationId
      TenantId = $TenantId
      Secret = $UnsecureSecret
   }
   
   $o = New-Object psobject -Property $properties;$o
} # End New-AzureServicePrincipal
