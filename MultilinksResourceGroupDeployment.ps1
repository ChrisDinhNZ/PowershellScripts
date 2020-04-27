. .\ChrisDinh-AzureUtilityScripts.ps1

Function New-MultilinksResourceGroupDeployment {
   <#
   .Synopsis
      Create new Multilinks resource group deployment.
   #>

   [CmdletBinding()]
   param (
      [Parameter(Mandatory)] [string] $AppServicePlanName,
      [Parameter(Mandatory)] [string] $AppServicePlanRGName,
      [Parameter(Mandatory)] [string] $AppServicePlanRGLocation,
      [Parameter(Mandatory)] [string] $AppServicePlanTier
   )

   $AppServicePlanParameters = @{
      'Name' = $AppServicePlanName
      'ResourceGroupName' = $AppServicePlanRGName
      'Location' = $AppServicePlanRGLocation
      'Tier' = $AppServicePlanTier
   }

   New-AzureAppServicePlan @AppServicePlanParameters
} # New-MultilinksResourceGroupDeployment
