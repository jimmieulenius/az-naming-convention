param (
    [Switch]
    $Region,

    [Switch]
    $ResourceType
)

& "$PSScriptRoot/_functions/Import-FunctionScript.ps1" `
    -Name @(
        'Build-ConfigComponentTemplate/',
        'Build-ConfigTemplate/',
        'Build-PlaceholderConfig',
        'Initialize-RegionConfig',
        'Initialize-ResourceTypeConfig'
    ) `
    -AllowClobber

$configBasePath = "$PSScriptRoot/../../../config"
$configPlaceholdersPath = "$configBasePath/placeholders"
$configPlaceholdersPathItems = (
    Get-ChildItem `
        -Path $configPlaceholdersPath `
        -File
).FullName
$destinationBasePath = "$PSScriptRoot/../../../template/arm/"
$destinationConfigPath = "$PSScriptRoot/../../../template/arm/config"
"$PSScriptRoot/../../../template/arm"

if ($ResourceType) {
    $configFile = Initialize-ResourceTypeConfig `
        -Destination $configBasePath `
        -PassThru

    Build-PlaceholderConfig `
        -ConfigPath $configFile.FullName `
        -Name 'RESOURCE_TYPE' `
        -Destination $configPlaceholdersPath `
        -Type 'lookup' `
        -Process {
            $result = [Ordered]@{}

            if ($_.abbreviation) {
                $result.value = $_.abbreviation
            }

            $result
        }
}

if ($Region) {
    $configFile = Initialize-RegionConfig `
        -Destination $configBasePath `
        -PassThru

    Build-PlaceholderConfig `
        -ConfigPath $configFile.FullName `
        -Name 'REGION' `
        -Destination $configPlaceholdersPath `
        -Type 'lookup' `
        -Process {
            $result = [Ordered]@{}

            if ($_.abbreviation) {
                $result.value = $_.abbreviation
            }

            $result
        }
}

Build-ConfigComponentTemplate `
    -ConfigPath @(
        "$configBasePath/format.json"
    ) `
    -Destination "$destinationConfigPath/format.json"

Build-ConfigComponentTemplate `
    -ConfigPath $configPlaceholdersPathItems `
    -Destination "$destinationConfigPath/placeholders.json"

Build-ConfigTemplate `
    -Placeholder $configPlaceholdersPathItems `
    -Destination $destinationBasePath