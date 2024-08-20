param (
    [Parameter(Mandatory = $true)]
    [String]
    $Destination,

    [Switch]
    $PassThru
)

& "$PSScriptRoot/Import-FunctionScript.ps1" `
    -Name @(
        'Set-Casing'
    ) `
    -AllowClobber

New-Item `
    -Path $Destination `
    -ItemType 'Directory' `
    -ErrorAction 'SilentlyContinue'
| Out-Null

$destinationPath = "$Destination/region.json"

if (
    Test-Path `
        -Path $destinationPath `
        -PathType 'Leaf'
) {
    $content = Get-Content `
        -Path $destinationPath `
        -Raw `
    | ConvertFrom-Json `
        -AsHashtable
}
else {
    $content = @{}
}

az account list-locations `
    --query '[?type == ''Region'' && metadata.regionType == ''Physical''].name' `
| ConvertFrom-Json `
    -AsHashtable
| ForEach-Object {
    if (-not $content.ContainsKey($_)) {
        $content.$_ = @{
            abbreviation = '<TODO>'
        }
    }
}

$result = [Ordered]@{}

$content.GetEnumerator() `
| Sort-Object `
    -Property 'Key' `
| ForEach-Object {
    $result.($_.Key) = $_.Value
}

$output = New-Item `
    -Path $destinationPath `
    -ItemType 'File' `
    -Value (
        $result
        | ConvertTo-Json `
            -Depth 100
    ) `
    -Force

if ($PassThru) {
    return $output
}