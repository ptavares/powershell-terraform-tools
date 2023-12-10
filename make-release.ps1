param (
    [Parameter(Mandatory)]
    [string]$versionBump
)

###############################################################################
# Contants
###############################################################################

# Define the path to module manifest file
$manifestPath = "terraform-tools\terraform-tools.psd1"

###############################################################################
# Check Scripts Inputs
###############################################################################

# Check if version bump is provided
if (-not $versionBump) {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Output "Usage: .\$scriptName -versionBump <major|minor|patch>"
    Write-Output "Please provide a version bump parameter."
    exit
}

# Validate user input
if ($versionBump -notin @('major', 'minor', 'patch')) {
    Write-Output "Invalid input. Please enter 'major', 'minor', or 'patch'."
    exit
}

###############################################################################
# Check Code
###############################################################################

# Run PSScriptAnalyzer on ps1 files
$analysisResultsPS1 = Invoke-ScriptAnalyzer -Path *.ps1 -Recurse
# Run PSScriptAnalyzer on psm1 files
$analysisResultsPSM1 = Invoke-ScriptAnalyzer -Path *.psm1 -Recurse

# Check if there are any issues found
if ($analysisResultsPS1.Count -gt 0) {
    Write-Output "PS1 Script contains code style issues:"
    foreach ($issue in $analysisResultsPS1) {
        Write-Output "$($issue.RuleName): $($issue.Message) [Line $($issue.Line)]"
    }
}

# Check if there are any issues found
if ($analysisResultsPSM1.Count -gt 0) {
    Write-Output "PSM1 Script contains code style issues:"
    foreach ($issue in $analysisResultsPSM1) {
        Write-Output "$($issue.RuleName): $($issue.Message) [Line $($issue.Line)]"
    }
}

if ($analysisResultsPS1.Count -gt 0 -or $analysisResultsPSM1.Count -gt 0) { exit 1 }

# Run Test-ModuleManifest on module manifest
$manifestTestResult = Test-ModuleManifest -Path $manifestPath

# Check if result is OK
if ($manifestTestResult) {
    Write-Output "Module manifest test passed."
} else {
    Write-Output "Module manifest test failed. Please check the manifest file for errors."
    exit 1
}

###############################################################################
# Update and Tag with new version
###############################################################################

# Get the current version from the module manifest
$currentVersion = (Get-Content $manifestPath | Select-String -Pattern '^\s*ModuleVersion\s*=\s*\''.*\''') -replace '.*(\d+\.\d+\.\d+).*', '$1'

# Assuming $currentVersion is in the format 'major.minor.patch'
$tagVersionComponents = $currentVersion -split '\.'
$major = [int]$tagVersionComponents[0]
$minor = [int]$tagVersionComponents[1]
$patch = [int]$tagVersionComponents[2]

# Increment the appropriate component
switch ($versionBump) {
    'major' { $major++; $minor = 0; $patch = 0 }
    'minor' { $minor++; $patch = 0 }
    'patch' { $patch++ }
}

# Create the new version string
$newVersion = "$major.$minor.$patch"

$tagExists = git tag -l $newVersion

if ($tagExists) {
    Write-Output "Tag $newVersion already exists. Please check your Git history"
    exit 1
}

# Update the ModuleVersion in the manifest
(Get-Content $manifestPath) -replace '^\s*ModuleVersion\s*=\s*\''.*\''', "ModuleVersion = '$newVersion'" | Set-Content $manifestPath

# Create CHANGELOG.md
docker container run -it -v ${PWD}:/app --rm yvonnick/gitmoji-changelog:latest update $newVersion

# Commit the change
git add --all
git commit -m ":bookmark: Bump version to $newVersion"

# Create a new Git tag
git tag -a $newVersion -m ":bookmark: Version $newVersion"

# Push changes to the remote repository
git push origin master --tags

Write-Output "ModuleVersion updated to $newVersion. Changes committed, tagged, and pushed."
