param(
    [Parameter(Mandatory = $true)]
    [string]$PythonExe,

    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs = @()
)

$ErrorActionPreference = "Stop"

[Console]::InputEncoding = [Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
chcp 65001 > $null
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

if (-not (Test-Path -LiteralPath $PythonExe)) {
    throw "Python executable not found: $PythonExe"
}

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Python script not found: $ScriptPath"
}

& $PythonExe $ScriptPath @ScriptArgs
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    exit $exitCode
}
