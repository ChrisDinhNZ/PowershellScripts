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
      'Name'              = $AppServicePlanName
      'ResourceGroupName' = $AppServicePlanRGName
      'Location'          = $AppServicePlanRGLocation
      'Tier'              = $AppServicePlanTier
   }

   New-AzureAppServicePlan @AppServicePlanParameters
} # New-MultilinksResourceGroupDeployment

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
      [Parameter(Mandatory)] [string] $AppServicePlanTier,
      [Parameter(Mandatory)] [string] $ResourceGroupLocation,
      [Parameter(Mandatory)] [string] $ResourceGroupName,
      [Parameter(Mandatory)] [string] $TemplateFile,
      [Parameter(Mandatory)] [string] $TemplateParametersFile
   )

   $AppServicePlanParameters = @{
      'Name'              = $AppServicePlanName
      'ResourceGroupName' = $AppServicePlanRGName
      'Location'          = $AppServicePlanRGLocation
      'Tier'              = $AppServicePlanTier
   }

   New-AzureAppServicePlan @AppServicePlanParameters

   try {
      [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ', '_'), '3.0.0')
   }
   catch { }

   $ErrorActionPreference = 'Stop'
   Set-StrictMode -Version 3

   $TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'ARMDeploymentFiles', $TemplateFile))
   $TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'ARMDeploymentFiles', $TemplateParametersFile))

   $MultilinksResourceGroupParameters = @{
      'ResourceGroupLocation'  = $ResourceGroupLocation
      'ResourceGroupName'      = $ResourceGroupName
      'TemplateFile'           = $TemplateFile
      'TemplateParametersFile' = $TemplateParametersFile
   }

   # Create the resource group only when it doesn't already exist
   if ($null -eq (Get-AzResourceGroup -Name $MultilinksResourceGroupParameters.ResourceGroupName -Location $MultilinksResourceGroupParameters.ResourceGroupLocation -Verbose -ErrorAction SilentlyContinue)) {
      New-AzResourceGroup -Name $MultilinksResourceGroupParameters.ResourceGroupName -Location $MultilinksResourceGroupParameters.ResourceGroupLocation -Verbose -Force -ErrorAction Stop
   }

   # $OptionalParameters = New-Object -TypeName Hashtable
   # New-AzResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
   #                                  -ResourceGroupName $ResourceGroupName `
   #                                  -TemplateFile $TemplateFile `
   #                                  -TemplateParameterFile $TemplateParametersFile `
   #                                  @OptionalParameters `
   #                                  -Force -Verbose `
   #                                  -ErrorVariable ErrorMessages
   # 
   # if ($ErrorMessages) {
   #    Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
   # }

} # New-MultilinksResourceGroupDeployment