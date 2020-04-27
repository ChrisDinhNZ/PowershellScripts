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

   <# Source material used:
      https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-3.7.0
   #>
} # End New-AzureServicePrincipal

Function Connect-AzureServicePrincipal {
   <#
   .Synopsis
      Connect-AzAccount with service principal.
   #>

   [CmdletBinding()]
   param (
      [Parameter(Mandatory)] [string] $TenantId,
      [Parameter(Mandatory)] [SecureString] $Password,
      [Parameter(Mandatory)] [string] $ApplicationId
   )

   $PSCredential = New-Object System.Management.Automation.PSCredential($ApplicationId , $Password)
   Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $PSCredential
} # Connect-AzureServicePrincipal

Function New-AzureAppServicePlan {
   <#
   .Synopsis
      Create new app service plan under specified resource group.
   #>

   [CmdletBinding()]
   param (
      [Parameter(Mandatory)] [string] $Name,
      [Parameter(Mandatory)] [string] $ResourceGroupName,
      [string] $Location = "southeastasia",
      [string] $Tier = "F1"
   )

   $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue

   if ($null -eq $ResourceGroup) {
      # Create new resource group.
      New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
   }
   else {
      # Resource group exists, app service plan should be at the same location.
      $Location = $ResourceGroup.Location
   }

   New-AzAppServicePlan -Name $Name -ResourceGroupName $ResourceGroupName -Location $Location -Tier $Tier -Verbose -ErrorAction Stop
} # Connect-AzureServicePrincipal

