# #########################################################
#       PowerShell script for Terraform Tools plugin
#
#   Author: Patrick Tavares <tavarespatrick01@gmail.com>
# #########################################################
. $PSScriptRoot\terraform-tools-aliases.ps1

# =========================================================
# Define Module Constants
# =========================================================
$API_GITUB = "https://api.github.com/repos"
$TF_DOCS_RELEASE = "terraform-docs/terraform-docs/releases"
$TF_SEC_RELEASE = "aquasecurity/tfsec/releases"
$TF_LINT_RELEASE = "terraform-linters/tflint/releases"
$TF_AUTO_MV_RELEASE = "busser/tfautomv/releases"
$TF_SWITCHER_RELEASE = "warrensbox/terraform-switcher/releases"

# =========================================================
# Define Local Module directory
# =========================================================
$env:TF_TOOLS_HOME = "$env:USERPROFILE\.terrafom-tools"

# =========================================================
# Define Module file to store tools version
# =========================================================
$TF_DOCS_VERSION_FILE = Join-Path $env:TF_TOOLS_HOME "version_tfdocs.txt"
$TF_SEC_VERSION_FILE = Join-Path $env:TF_TOOLS_HOME "version_tfsec.txt"
$TF_LINT_VERSION_FILE = Join-Path $env:TF_TOOLS_HOME "version_tflint.txt"
$TF_AUTO_MV_VERSION_FILE = Join-Path $env:TF_TOOLS_HOME "version_tfautomv.txt"
$TF_SWITCHER_VERSION_FILE = Join-Path $env:TF_TOOLS_HOME "version_tfswitch.txt"

# =========================================================
# Install tools Functions
# =========================================================

function Write-ColorOutput {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False, Position = 1, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)][Object] $Object,
        [Parameter(Mandatory = $False, Position = 2, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)][ConsoleColor] $ForegroundColor,
        [Parameter(Mandatory = $False, Position = 3, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)][ConsoleColor] $BackgroundColor,
        [Switch]$NoNewline
    )    


    # Always write (if we want just a NewLine)
    if ($Object -eq $null) {
        $Object = ""
    }

    if ($NoNewline) {
        [Console]::Write($Object)
    }
    else {
        Write-Output $Object
    }

   
}

<#
.SYNOPSIS
    Centralized Module Log.

.DESCRIPTION
    Centralized Module Log.

.PARAMETER Color
    Color used to Log Message

.PARAMETER Message
    Message to output
#>
function Write-TerraformToolLog {
    param (
        [Parameter(Mandatory)]
        [string] $Color,
        [Parameter(Mandatory)]
        [string] $Message
    )

    # Save previous colors
    $previousForegroundColor = $host.UI.RawUI.ForegroundColor

    # Set ForegroundColor
    $host.UI.RawUI.ForegroundColor = $Color

    # Output Message
    Write-Output "[Terraform-Module] $Message"

    # Restore previous colors
    $host.UI.RawUI.ForegroundColor = $previousForegroundColor
}

<#
.SYNOPSIS
    Retrieve last version of a tool from Github.

.DESCRIPTION
    Retrieve last version of a tool from Github using Github API.

.PARAMETER Tool
    Color used to Log Message.

.OUTPUTS
    string. The last version of the tool founded.
#>
function Get-TerraformToolLastVersion {
    param (
        [Parameter(Mandatory)]
        [string]$ToolName
    )

    return (Invoke-RestMethod -Uri "$API_GITUB/$ToolName/latest").tag_name
}

<#
.SYNOPSIS
    Download and install a tool.

.DESCRIPTION
    Download and install Version ToolName in DestDir .

.PARAMETER ToolName
    ToolName to Download.

.PARAMETER Version
    Version of the tool to Download.

.PARAMETER DestDir
    Directory where tool will be stored.
#>
function Install-DownloadTerraformTools {
    param (
        [Parameter(Mandatory)]
        [string] $ToolNameName,
        [Parameter(Mandatory)]
        [string] $Version,
        [Parameter(Mandatory)]
        [string] $DestDir
    )

    # TODO : Add try catch Exception

    Write-TerraformToolLog "Blue" "  -> Download and install $ToolNameName $Version"
    $architecture = ($env:PROCESSOR_ARCHITECTURE).ToLower()

    switch ($ToolNameName) {
        "tfdocs" {
            $url = "https://github.com/$TF_DOCS_RELEASE/download/$Version/terraform-docs-$Version-windows-$architecture.zip"
            Invoke-RestMethod -Uri $url -OutFile "$DestDir\tmp.zip"
            Expand-Archive -Path "$DestDir\tmp.zip"-DestinationPath $DestDir -Force | Out-Null
            Remove-Item "$DestDir\*.zip"
            $Version | Out-File $TF_DOCS_VERSION_FILE
        }
        "tfsec" {
            $url = "https://github.com/$TF_SEC_RELEASE/download/$Version/tfsec-checkgen-windows-$architecture.exe"
            Invoke-RestMethod -Uri $url -OutFile "$DestDir\tfsec.exe"
            Set-ItemProperty -Path "$DestDir\tfsec.exe" -Name IsReadOnly -Value $false
            $Version | Out-File $TF_SEC_VERSION_FILE
        }
        "tflint" {
            $url = "https://github.com/$TF_LINT_RELEASE/download/$Version/tflint_windows_$architecture.zip"
            Invoke-RestMethod -Uri $url -OutFile "$DestDir\tmp.zip"
            Expand-Archive -Path "$DestDir\tmp.zip" -DestinationPath $DestDir -Force | Out-Null
            Remove-Item "$DestDir\tmp.zip"
            $Version | Out-File $TF_LINT_VERSION_FILE
        }
        "tfautomv" {
            $subVersion = $Version.Substring(1)
            $url = "https://github.com/$TF_AUTO_MV_RELEASE/download/$Version/tfautomv_${subVersion}_windows_$architecture.zip"
            Invoke-RestMethod -Uri $url -OutFile "$DestDir\tmp.zip"
            Expand-Archive -Path "$DestDir\tmp.zip" -DestinationPath $DestDir -Force | Out-Null
            Remove-Item "$DestDir\tmp.zip"
            $Version | Out-File $TF_AUTO_MV_VERSION_FILE
        }
        "tfswitch" {
            $url = "https://github.com/$TF_SWITCHER_RELEASE/download/$Version/terraform-switcher_${Version}_windows_$architecture.zip"
            Invoke-RestMethod -Uri $url -OutFile "$DestDir\tmp.zip"
            Expand-Archive -Path "$DestDir\tmp.zip" -DestinationPath $DestDir -Force | Out-Null
            Remove-Item "$DestDir\tmp.zip"
            $Version | Out-File $TF_SWITCHER_VERSION_FILE
        }
        default {
            Write-TerraformToolLog "Red" "Unknown tool"
            return
        }
    }

    Write-TerraformToolLog "Green" "  -> Install OK for $ToolNameName at version $Version"
}

<#
.SYNOPSIS
    Managed the installation of a Terraform tool.

.DESCRIPTION
        Managed the installation of a Terraform tool (get last version + donwload and install).

.PARAMETER ToolName
    ToolName to Download.

.PARAMETER ReleaseURL
    URL to find the last tool version available.

#>
function Install-TerraformTool {
    param (
        [Parameter(Mandatory)]
        [string] $ToolName,
        [Parameter(Mandatory)]
        [string] $ReleaseURL
    )

    Write-TerraformToolLog "Blue" "   --> $ToolName <--"
    $ToolNameDir = Join-Path $env:TF_TOOLS_HOME $ToolName
    New-Item -Path $ToolNameDir -ItemType Directory | Out-Null

    $lastVersion = Get-TerraformToolLastVersion $ReleaseURL
    Write-TerraformToolLog "Blue" "-> retrieve last version of $ToolName..."
    Install-DownloadTerraformTools -ToolName $ToolName -Version $lastVersion -DestDir $ToolNameDir
}

<#
.SYNOPSIS
    Managed the installation of all Terraform tools.

.DESCRIPTION
        Managed the installation of all Terraform tools (create directory + run installation).

#>
function Install-TerraformTools {
  
    Write-TerraformToolLog "Blue" "#############################################"
    Write-TerraformToolLog "Blue" "Installing Terraform tools..."
    Write-TerraformToolLog "Blue" "-> Creating Terraform tools home dir : $env:TF_TOOLS_HOME"
    New-Item -Path $env:TF_TOOLS_HOME -ItemType Directory | Out-Null

    # Install tfdocs
    Install-TerraformTool "tfdocs" $TF_DOCS_RELEASE
    # Install tfsec
    Install-TerraformTool "tfsec" $TF_SEC_RELEASE
    # Install tflint
    Install-TerraformTool "tflint" $TF_LINT_RELEASE
    # Install tfautomv
    Install-TerraformTool "tfautomv" $TF_AUTO_MV_RELEASE
    # Install tfswitch
    Install-TerraformTool "tfswitch" $TF_SWITCHER_RELEASE

    Write-TerraformToolLog "Blue" "#############################################"
}

<#
.SYNOPSIS
    Update a Terraform tool to the last available version.

.DESCRIPTION
        Perform an update for a Terraform tools. If the tools version is outdated,
        will remove old one and replace it by the last version.

.PARAMETER ToolName
    ToolName to check.

.PARAMETER ReleaseFile
    File that contains the current version of the tool.

.PARAMETER ReleaseURL
    URL to find the last tool version available.

#>
function Update-TerraformTool {
    param (
        [Parameter(Mandatory)]
        [string] $ToolName,
        [Parameter(Mandatory)]
        [string] $ReleaseFile,
        [Parameter(Mandatory)]
        [string] $ReleaseURL
    )

    $currentVersion = Get-Content $ReleaseFile
    $lastVersion = Get-TerraformToolLastVersion $ReleaseURL

    if ($lastVersion -ge $currentVersion) {
        Write-TerraformToolLog "Blue" "-> Checking $ToolName..."
        Write-TerraformToolLog "Green" "Already up to date, current version : $currentVersion"
    }
    else {
        Write-TerraformToolLog "Blue" "-> Updating $ToolName..."
        Install-TerraformTool $ToolName $ReleaseURL
        Write-TerraformToolLog "Green" "Update OK"
    }
}

<#
.SYNOPSIS
    Managed the installation of all Terraform tools.

.DESCRIPTION
    Managed the installation of all Terraform tools (create directory + run installation).

#>
function Update-TerraformTools {
  
    Write-TerraformToolLog "Blue" "#############################################"
    Write-TerraformToolLog "Blue" "Checking new version of Terraform tools..."

    # Update tfdocs
    Update-TerraformTool -ToolName "tfdocs" -ReleaseFile $TF_DOCS_VERSION_FILE -ReleaseURL $TF_DOCS_RELEASE
    # Update tfsec
    Update-TerraformTool -ToolName "tfsec" -ReleaseFile $TF_SEC_VERSION_FILE -ReleaseURL $TF_SEC_RELEASE
    # Update tflint
    Update-TerraformTool -ToolName "tflint" -ReleaseFile $TF_LINT_VERSION_FILE -ReleaseURL $TF_LINT_RELEASE
    # Update tfautomv
    Update-TerraformTool -ToolName "tfautomv" -ReleaseFile $TF_AUTO_MV_VERSION_FILE -ReleaseURL $TF_AUTO_MV_RELEASE
    # Update tfswitch
    Update-TerraformTool -ToolName "tfswitch" -ReleaseFile $TF_SWITCHER_VERSION_FILE -ReleaseURL $TF_SWITCHER_RELEASE

    Write-TerraformToolLog "Blue" "#############################################"
}

# =========================================================
# # Install and/or load terraform tools function
# =========================================================
function TerraformToolsAddToPath {
    param (
        [string] $DirectoryToAdd
    )

    # Get Currecnt user PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    # Check if directoryToAdd is already PATH
    if (-not $currentPath.Contains($DirectoryToAdd)) {
        [System.Environment]::SetEnvironmentVariable('PATH', "$currentPath;$DirectoryToAdd", [System.EnvironmentVariableTarget]::User)
    }
}

function TerraformToolsLoads {
    Write-TerraformToolLog "Blue" "Expanding user PATH with tools..."
    # Export PATH
    TerraformToolsAddToPath "$env:TF_TOOLS_HOME\tfdocs"
    TerraformToolsAddToPath "$env:TF_TOOLS_HOME\tfsec"
    TerraformToolsAddToPath "$env:TF_TOOLS_HOME\tflint"
    TerraformToolsAddToPath "$env:TF_TOOLS_HOME\tfautomv"
    TerraformToolsAddToPath "$env:TF_TOOLS_HOME\tfswitch"
    Write-TerraformToolLog "Green" "Expanding user PATH with tools OK"
}

# Install terraform and all tools if it isn't already installed
if (-not (Test-Path "$env:TF_TOOLS_HOME\version_*.txt") -or (Get-ChildItem "$env:TF_TOOLS_HOME\version_*.txt").Count -ne 5 ) {
    Install-TerraformTools
}

# Load terraform and all tools if it is installed
if ((Get-ChildItem "$env:TF_TOOLS_HOME\version_*.txt").Count -gt 0) {
    TerraformToolsLoads
}

