. $PSScriptRoot\terraform-tools-utils.ps1

# =========================================================
# Define all lower levels aliases
# =========================================================

Set-Alias -Name tf -Value terraform
function tff { tf fmt }
function tfv { tf validate }
function tfi { tf init }
function tfp { tf plan }
function tfa { tf apply }
function tfd { tf destroy }
function tfo { tf output }
function tfr { tf refresh }
function tfs { tf show }
function tfw { tf workspace }

# =========================================================
# All others aliases
# =========================================================
# Basics
function tffr { tff -recursive }
function tfip { tfi ; tfp }
function tfia { tfi ; tfa }
function tfid { tfi ; tfd }
# Warning: with auto-approve
function tfa! { tfa -auto-approve }
function tfia! { tfi ; tfa! }
function tfd! { tfd -auto-approve }
function tfid! { tfi ; tfd! }

# Utils
function tfversion { tf version }


<#
.SYNOPSIS
	tf workspace select -or-create $WorkspaceName
#>
function tfws {
    param (
        [Parameter(Mandatory)]
        [string] $WorkspaceName
    )

    if (-not $WorkspaceName) {
        Write-Output "> Usage:  tfws [workspace_name]"
    }
    elseif ($Argument.Count -gt 1) {
        Write-Output "> Usage:  tfws [workspace_name]"
    }
    else {
        $count = (Get-ChildItem -Path $PWD -Filter "*.tf" -File | Measure-Object).Count
        if ($count -le 0) {
            Write-Output "> Not in terraform directory"
        }
        else {
            tf workspace select -or-create $WorkspaceName
        }
    }
}

# =========================================================
# For Tools
# =========================================================
# Keep tfswitch and terraform binaries in USERPROFILE
function tfswitch {
    tfswitch.exe --bin=$env:TF_TOOLS_HOME\tfswitch\terraform.exe
}
