param (
    [Parameter(Mandatory = $true)]
    [String]
    $ConfigPath,

    [String]
    $Name,

    [Parameter(Mandatory = $true)]
    [String]
    $Destination,

    [ValidateSet(
        'instance',
        'lookup',
        'text',
        'unique'
    )]
    [String]
    $Type = 'text',

    [ScriptBlock]
    $Process
)

function Invoke-Item {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [Object]
        $InputObject,

        [ScriptBlock]
        $Process
    )

    process {
        & $Process
    }
}

if (-not $Name) {
    $Name = Split-Path `
        -Path $ConfigPath `
        -LeafBase
}

New-Item `
    -Path $Destination `
    -ItemType 'Directory' `
    -ErrorAction 'SilentlyContinue'
| Out-Null

$fileName = Split-Path `
    -Path $ConfigPath `
    -LeafBase

$result = @{
    $Name =  [Ordered]@{
        '$type' = 'lookup'
    }
}

switch ($Type) {
    ('lookup') {
        $source = [Ordered]@{}

        (
            Get-Content `
                -Path $ConfigPath `
                -Raw
            | ConvertFrom-Json `
                -AsHashtable
        ).GetEnumerator() `
        | ForEach-Object {
            $source.($_.Key) = $_.Value `
            | Invoke-Item `
                -Process $Process
        }

        $result.$Name.source = $source
    }
}

New-Item `
    -Path "$Destination/$fileName.json" `
    -ItemType 'File' `
    -Value (
        $result `
        | ConvertTo-Json `
            -Depth 100
    ) `
    -Force
| Out-Null