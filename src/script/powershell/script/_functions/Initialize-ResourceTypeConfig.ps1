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

$response = Invoke-WebRequest `
    -Uri 'https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations'

[Xml] $xml = "<root>$($response.Content.Split('<!-- cspell:ignoreRegExp [_\*][a-z]+[\\-] -->')[1].Split('<h2 id="next-step">Next step</h2>')[0])</root>"

$destinationPath = "$Destination/resourceType.json"

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

$xml
| Select-Xml `
    -XPath "/root/table/tbody/tr"
| ForEach-Object {
    if (
        $_.Node.ChildNodes[0].InnerText -notin @(
            'DNS',
            'DNS zone'
        )
    ) {
        @{
            Key = (
                (
                    $_.Node.ChildNodes[0].InnerText `
                    | Set-Casing `
                        -Casing 'CamelCase'
                ).
                Replace('(internal)', 'Internal').
                Replace('(external)', 'External') `
                -replace '\(([^\)]+)\)', '' `
                -replace '.Name$', '' `
                -replace '^AKS', 'aks' `
                -replace '^API', 'api' `
                -replace '^CDN', 'cdn' `
                -replace '^DNS', 'dns' `
                -replace '^HD', 'hd' `
                -replace '^IOT', 'iot' `
                -replace '^IP', 'ip' `
                -replace '^NAT', 'nat' `
                -replace '^SQL', 'sql' `
                -replace '^SSH', 'ssh' `
                -replace '^VM', 'vm' `
                -replace '^VPN', 'vpn'
            )
            Value = [Ordered]@{
                abbreviation = $_.Node.ChildNodes[2].InnerText
                namespace = (
                    $_.Node.ChildNodes[1].InnerText `
                    -replace '\(([^\)]+)\)', ''
                ).Trim()
            }
        }
    }
} `
# | Sort-Object `
#     -Property Key `
| ForEach-Object {
    $content.($_.Key) = $_.Value
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