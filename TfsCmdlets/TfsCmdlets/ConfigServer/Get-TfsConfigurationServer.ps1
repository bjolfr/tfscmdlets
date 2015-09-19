<#

.SYNOPSIS
    Gets information about a configuration server.
#>
Function Get-TfsConfigurationServer
{
	[CmdletBinding(DefaultParameterSetName='Get by server')]
	[OutputType([Microsoft.TeamFoundation.Client.TfsConfigurationServer])]
	Param
	(
		[Parameter(Position=0, ParameterSetName='Get by server', Mandatory=$true)]
        [AllowNull()]
		[object] 
		$Server,
	
		[Parameter(Position=0, ParameterSetName="Get current")]
        [switch]
        $Current,

		[Parameter(Position=1, ParameterSetName='Get by server')]
		[System.Management.Automation.Credential()]
		[System.Management.Automation.PSCredential]
		$Credential
	)

	Process
	{
		if ($Current)
		{
			return $Global:TfsServerConnection
        }

		if ($Server -is [Microsoft.TeamFoundation.Client.TfsConfigurationServer])
		{
			return $Server
		}

		if ($Server -is [Uri])
		{
			return _GetConfigServerFromUrl $Server $Credential
		}

		if ($Server -is [string])
		{
			if ([Uri]::IsWellFormedUriString($Server, [UriKind]::Absolute))
			{
				return _GetConfigServerFromUrl ([Uri] $Server) $Credential
			}

			if (-not [string]::IsNullOrWhiteSpace($Server))
			{
				return _GetConfigServerFromName $Server $Credential
			}

			$Server = $null
		}

		throw "No TFS connection information available. Either supply a valid -Server argument or use Connect-TfsConfigurationServer prior to invoking this cmdlet."
	}
}

# =================
# Helper Functions
# =================

Function _GetConfigServerFromUrl
{
	Param ($Url, $Cred)
	
	if ($Cred)
	{
		$configServer = New-Object Microsoft.TeamFoundation.Client.TfsConfigurationServer -ArgumentList ([Uri] $Url), ([System.Net.NetworkCredential] $cred)
	}
	else
	{
		$configServer = [Microsoft.TeamFoundation.Client.TfsConfigurationServerFactory]::GetConfigurationServer([Uri] $Url)
	}


	$configServer.EnsureAuthenticated()
	return $configServer
}

Function _GetConfigServerFromName
{
	Param ($Name, $Cred)

	$Servers = Get-TfsRegisteredConfigurationServer $Name
	
	foreach($Server in $Servers)
	{
		if ($Cred)
		{
			$configServer = New-Object Microsoft.TeamFoundation.Client.TfsConfigurationServer -ArgumentList ($Server.Uri), ([System.Net.NetworkCredential] $cred)
		}
		else
		{
			$configServer = [Microsoft.TeamFoundation.Client.TfsConfigurationServerFactory]::GetConfigurationServer($Server)
		}

		$configServer.EnsureAuthenticated()
		$configServer
	}
}
