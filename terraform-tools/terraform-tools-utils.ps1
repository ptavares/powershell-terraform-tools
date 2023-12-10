<#
.SYNOPSIS
	Format output for a specific alias definition.
.DESCRIPTION
	Format output for a specific alias definition.
	Get function standard definition or synopsis for help if defined
#>
function Format-AliasDefinition {
	param (
		[Parameter(Mandatory)]
		[string]$Definition
	)

	$definitionLines = $Definition.Trim() -split "`n" | ForEach-Object {
		$_.TrimStart("`t", ' ')
	}

	return $definitionLines -join "`n"
}


<#
.SYNOPSIS
	Get Terraform aliases' definition.
.DESCRIPTION
	Get definition of all Terraform aliases or specific alias.
.EXAMPLE
	PS C:\> Get-TerraformAliases
	Get definition of all aliases.
.EXAMPLE
	PS C:\> Get-TerraformAliases -Alias tfv
	Get definition of `tfv` alias.
#>
function Get-TerraformAliases {
	param (
		[string]$Alias
	)

	$esc = [char]27
	$nameColor = 32
	$descriptionColor = 33

	$ignoreFunctions = @(
		'Format-AliasDefinition',
		'Get-TerraformAliases',
		'Get-TerraformToolLastVersion',
		'Install-DownloadTerraformTools',
		'Install-TerraformTool',
		'Install-TerraformTools',
		'TerraformToolsAddToPath',
		'TerraformToolsLoads',
		'Update-TerraformTool',
		'Update-TerraformTools',
		'Write-TerraformToolLog'
	)

	$aliases = Get-Command -Module terraform-tools | Where-Object { $_ -notin $ignoreFunctions }

	$Alias = $Alias.Trim()
	if (-not [string]::IsNullOrEmpty($Alias)) {
		$foundAliases = $aliases | Where-Object -Property Name -Value $Alias -EQ
		if ($foundAliases) {
			$currentAlias = $foundAliases[0]
			$definition = Format-AliasDefinition $currentAlias.Definition
			$helpSynopsis = (Get-Help $currentAlias).Synopsis.Trim()
			$definition = if ($helpSynopsis -notcontains $currentAlias) { $helpSynopsis } else { $definition }
			return "  -> $esc[$($descriptionColor)m$($definition)$esc[0m"
		}
	}

	$aliases = $aliases | ForEach-Object {
		$name = $_.Name
		$definition = Format-AliasDefinition $_.Definition
		$definition = "$definition"
		$helpSynopsis = (Get-Help $_).Synopsis.Trim()
		$definition = if ($helpSynopsis -notcontains $_) { $helpSynopsis } else { $definition }

		[PSCustomObject]@{
			Name       = "    $esc[$($nameColor)m$name$esc[0m"
			Definition = "    $esc[$($descriptionColor)m$definition$esc[0m"
		}
	}

	Write-Output ""
	Write-Output "============================================="
	Write-Output "=    Aliases from terraform-tools Module    ="
	Write-Output "============================================="
	return Format-Table -InputObject $aliases -AutoSize -Wrap
}
