	### Author: @InvalidCanary
	### Purpose: Quick and dirty script: Transfers base settings from an existing server to a target
	### No error checking, but if server/vdir/etc doesn't exist or can't be pulled, no value will be written.
	### Note: Uses get-clientaccessserver instead of get-clientaccessservice to account for pulling from 2010.  Will result in command deprecation warning.  No impact on functionality.
	### Parameters: -Source [Server to copy settings from] -REQUIRED
	### Parameters: -TargetServer [Netbios name target] -REQUIRED
	### Example: .\transfer-settings.ps1 -Source PHOBOS -TargetServer DEIMOS
	 
	Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$sourceServer,
	[Parameter(Mandatory=$True)]
	[string]$targetServer
	)
	
	### Overrides for testing
	### $sourceServer="atlas"
	### $targetServer="phobos"
	$sourceOWA=Get-OwaVirtualDirectory -Server $sourceServer -ADPropertiesOnly
	$sourceECP=Get-ECPVirtualDirectory -Server $sourceServer -ADPropertiesOnly
	$sourceEWS=Get-webServicesVirtualDirectory -Server $sourceServer -ADPropertiesOnly
	$sourceEAS=Get-activeSyncVirtualDirectory -Server $sourceServer -ADPropertiesOnly
	$sourceOAB=Get-oabVirtualDirectory -Server $sourceServer -ADPropertiesOnly
	$sourceMAPI=Get-mapiVirtualDirectory -Server $sourceServer -ADPropertiesOnly
	$sourceOA=Get-outlookAnywhere -server $sourceServer -ADPropertiesOnly
	$sourceAutoDiscover=get-clientaccessserver $sourceServer
	
	Get-OwaVirtualDirectory -Server $targetServer -ADPropertiesOnly| Set-OwaVirtualDirectory -InternalUrl $sourceOWA.InternalUrl -ExternalURL $sourceOWA.ExternalURL
	Get-EcpVirtualDirectory -Server $targetServer -ADPropertiesOnly | Set-EcpVirtualDirectory -InternalUrl $sourceECP.InternalUrl -ExternalURL $sourceECP.ExternalURL
	Get-webServicesVirtualDirectory -Server $targetServer -ADPropertiesOnly | Set-webServicesVirtualDirectory -InternalUrl $sourceEWS.InternalUrl -ExternalURL $sourceEWS.ExternalURL
	Get-activesyncVirtualDirectory -Server $targetServer -ADPropertiesOnly | Set-activesyncVirtualDirectory -InternalUrl $sourceEAS.InternalUrl -ExternalURL $sourceEAS.ExternalURL
	Get-OABVirtualDirectory -Server $targetServer -ADPropertiesOnly | Set-OABVirtualDirectory -InternalUrl $sourceOAB.InternalUrl -ExternalURL $sourceOAB.ExternalURL
	Get-mapiVirtualDirectory -Server $targetServer -ADPropertiesOnly | Set-mapiVirtualDirectory -InternalUrl $sourceMAPI.InternalUrl -ExternalURL $sourceMAPI.ExternalURL
	Get-outlookanywhere -Server $targetServer -ADPropertiesOnly | Set-outlookanywhere -InternalHostname $sourceOA.InternalHostname -ExternalHostname $sourceOA.ExternalHostname -ExternalClientsRequireSsl $true -ExternalClientAuthenticationMethod Basic -InternalClientsRequireSsl $true
		
	get-clientaccessServer $targetServer| set-clientaccessServer -AutoDiscoverServiceInternalUri $sourceAutoDiscover.AutoDiscoverServiceInternalUri.AbsoluteUri
