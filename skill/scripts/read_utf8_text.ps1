param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
    throw "File not found: $Path"
}

Get-Content -LiteralPath $Path -Encoding UTF8
