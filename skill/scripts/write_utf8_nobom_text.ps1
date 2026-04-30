param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Text
)

$ErrorActionPreference = "Stop"

$dir = Split-Path -Parent $Path
if ($dir) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
