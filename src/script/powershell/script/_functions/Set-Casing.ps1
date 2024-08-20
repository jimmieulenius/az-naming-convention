param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    [String]
    $Value,

    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'CamelCase',
        'KebabCase',
        'PascalCase',
        'SnakeCase'
    )]
    [String]
    $Casing
)

$components = $Value.Split(' -_'.ToCharArray())

switch ($Casing) {
    {
        $_ -iin @(
            'CamelCase',
            'PascalCase'
        )
    } {
        $result = (
            $components `
            | ForEach-Object {
                if ($_.Trim()) {
                    "$(
                        $_.
                        Substring(0, 1).
                        ToUpper()
                    )$($_.Substring(1))"
                }
            }
        ) -join ''
    }
    ('KebabCase') {
        $result = $components -join '-'
    }
    ('SnakeCase') {
        $result = $components -join '_'
    }
}

if ($Casing -eq 'CamelCase') {
    $result = "$($result.Substring(0, 1).ToLower())$($result.Substring(1))"
}

return $result