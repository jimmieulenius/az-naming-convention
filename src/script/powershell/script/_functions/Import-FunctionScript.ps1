param (
    [Parameter(Mandatory = $true)]
    [String[]]
    $Name,

    [String]
    $BasePath,

    [String]
    $Namespace,

    [ValidateSet(
        'CurrentUserCurrentHost',
        'CurrentUserAllHosts',
        'AllUsersCurrentHost',
        'AllUsersAllHosts'
    )]
    [String]
    $ProfilePath,

    [Switch]
    $AllowClobber,

    [Switch]
    $Recurse
)

function Get-FunctionScript {
    param (
        [Parameter(Mandatory = $true)]
        [String[]]
        $ScriptName,

        [Parameter(Mandatory = $true)]
        [String[]]
        $Name,

        [String]
        $BasePath,

        [String]
        $Namespace,

        [Switch]
        $Recurse
    )
    @"
& "`$PSScriptRoot/$ScriptName" ``
    -Name @(
$(
    (
        $Name `
        | ForEach-Object {
            "$(' ' * 8)'$_'"
        }
    ) -join ",$([Environment]::NewLine)"
)
    )$(
        ($BasePath) `
            ? @"
 ``
    -BasePath '$(
        (
            Resolve-Path `
                -Path $BasePath
        ).Path
    )'
"@ `
            : $null
    )$(
        ($Namespace) `
            ? @"
 ``
    -Namespace '$Namespace'
"@ `
            : $null
    )$(
        ($Recurse) `
            ? @"
 ``
    -Recurse
"@ `
            : $null
    )
"@
}

$path = $Name | ForEach-Object {
    $extension = Split-Path `
        -Path $_ `
        -Extension
    $pathItem = "$(Join-Path ($BasePath ? $BasePath : $PSScriptRoot) $_)$(($extension) ? $extension : '*.ps1')"

    if (-not (
            Test-Path `
                -Path $pathItem
        )
    ) {
        $pathItem = $_
    }

    Get-ChildItem `
        -Path $pathItem `
        -Recurse:$Recurse `
    | ForEach-Object {
        (
            Resolve-Path `
                -Path $_.FullName
        ).Path
    }
}

if (-not $AllowClobber) {
    Get-Alias `
    | Where-Object {
        $_.Description -ieq '$FunctionScript'
    } `
    | ForEach-Object {
        Remove-Alias `
            $_.Name
    }
}

$path | ForEach-Object {
    $functionName = Split-Path  `
        -Path $_ `
        -LeafBase

    if ($Namespace) {
        $functionName = "$Namespace\$functionName"
    }

    Set-Alias `
        -Name $functionName `
        -Value $_ `
        -Scope 'Global' `
        -Description '$FunctionScript' `
        -Force
}

if ($ProfilePath) {
    $profileRoot = Split-Path `
        -Path $PROFILE.$ProfilePath

    New-Item `
        -Path $profileRoot `
        -ItemType 'Directory' `
        -Force `
    | Out-Null

    Copy-Item `
        -Path $PSCmdlet.MyInvocation.MyCommand.Source `
        -Destination $profileRoot `
        -Force

    $functionScriptPath = Join-Path $profileRoot "functionScript.ps1"
    $functionScriptNamespacePath = Join-Path $profileRoot "functionScript_$(($Namespace) ? $Namespace : 'default').ps1"

    New-Item `
        -Path $functionScriptNamespacePath `
        -ItemType 'File' `
        -Value (
            Get-FunctionScript `
                -ScriptName $PSCmdlet.MyInvocation.MyCommand.Name `
                -Name $path `
                -BasePath $BasePath `
                -Namespace $Namespace `
                -Recurse:$Recurse
        ) `
        -Force `
    | Out-Null

    if (
        (
            Test-Path `
                -Path $functionScriptPath
        ) `
        -and $AllowClobber
    ) {
        $script = "& `"$functionScriptNamespacePath`""
        $content = Get-Content `
            -Path $functionScriptPath

        if ($content -inotcontains $script) {
            Add-Content `
                -Path $functionScriptPath `
                -Value @"

$script
"@ `
                -Force
        }
    }
    else {
        New-Item `
            -Path $functionScriptPath `
            -ItemType 'File' `
            -Value "& `"$functionScriptNamespacePath`"" `
            -Force `
        | Out-Null
    }

if (-not (
    Test-Path `
        -Path $PROFILE.$ProfilePath
    )
) {
    New-Item `
        -Path $PROFILE.$ProfilePath `
        -ItemType 'File' `
    | Out-Null
}

    $stringBuilder = [System.Text.StringBuilder]::new(
        (
            (
                Get-Content `
                    -Path $PROFILE.$ProfilePath `
                    -Raw
            ) ?? ''
        )
    )
    $script = "& `"$functionScriptPath`""

    if (-not $stringBuilder.ToString().Contains($script)) {
        $stringBuilder.AppendLine(@"

$script
"@) `
        | Out-Null
    }

    Set-Content `
        -Path $PROFILE.$ProfilePath `
        -Value $stringBuilder.ToString().Trim() `
        -Force
}