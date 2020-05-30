. .\ChrisDinh-AzureUtilityScripts.ps1

Function New-MultilinksResourceGroupDeployment {
   <#
   .Synopsis
      Create new Multilinks resource group deployment.
   #>

   [CmdletBinding()]
   param (
      [Parameter(Mandatory)] [string] $KeyVaultName,
      [Parameter(Mandatory)] [string] $KeyVaultRGName,

      [Parameter(Mandatory)] [string] $ResourceGroupName,
      [Parameter(Mandatory)] [string] $ResourceGroupLocation,
      [Parameter(Mandatory)] [string] $TemplateFile,
      [Parameter(Mandatory)] [string] $TemplateParametersFile
   )

   try {
      [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ', '_'), '3.0.0')
   }
   catch { }

   $ErrorActionPreference = 'Stop'
   Set-StrictMode -Version 3

   $TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'ARMDeploymentFiles', $TemplateFile))
   $TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'ARMDeploymentFiles', $TemplateParametersFile))

   # Create the resource group only when it doesn't already exist
   if ($null -eq (Get-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -ErrorAction SilentlyContinue)) {
      New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop
   }

   $MultilinksResourceGroupParameters = @{
      'KeyVaultName'             = $KeyVaultName
      'KeyVaultRGName'           = $KeyVaultRGName
   }

   New-AzResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                    -ResourceGroupName $ResourceGroupName `
                                    -TemplateFile $TemplateFile `
                                    -TemplateParameterFile $TemplateParametersFile `
                                    @MultilinksResourceGroupParameters `
                                    -Force -Verbose `
                                    -ErrorVariable ErrorMessages
   
   if ($ErrorMessages) {
      Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
   }

} # New-MultilinksResourceGroupDeployment