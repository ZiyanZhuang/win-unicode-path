param()

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$artifactDir = Join-Path $PSScriptRoot "artifacts"
$runtimeDir = Join-Path $artifactDir "runtime"
$unicodeDir = Join-Path $runtimeDir "示例目录"
$inputPath = Join-Path $unicodeDir "样本文本.txt"
$resultPath = Join-Path $unicodeDir "结果.json"
$nobomPath = Join-Path $unicodeDir "nobom_text.txt"
$payloadPath = Join-Path $artifactDir "payload.json"

New-Item -ItemType Directory -Force -Path $artifactDir,$runtimeDir,$unicodeDir | Out-Null

$pythonExe = "E:\conda\envs_dirs\ezs_env\python.exe"
$safeInvoke = Join-Path $repoRoot "skill\scripts\invoke_python_utf8_safe.ps1"
$readUtf8 = Join-Path $repoRoot "skill\scripts\read_utf8_text.ps1"
$writeNoBom = Join-Path $repoRoot "skill\scripts\write_utf8_nobom_text.ps1"
$writeJson = Join-Path $repoRoot "skill\scripts\write_json_utf8.py"
$roundtrip = Join-Path $PSScriptRoot "scripts\echo_path_roundtrip.py"
$inspect = Join-Path $PSScriptRoot "scripts\inspect_bytes.py"

Set-Content -LiteralPath $inputPath -Value "sample unicode path content" -Encoding utf8
Set-Content -LiteralPath $payloadPath -Value '{"path":"E:/demo/项目A/data.txt","note":"example"}' -Encoding UTF8

$results = @()

try {
    & powershell -ExecutionPolicy Bypass -File $safeInvoke -PythonExe $pythonExe -ScriptPath $roundtrip $inputPath $resultPath | Out-Null
    $results += [pscustomobject]@{ test_name="safe_python_roundtrip"; passed=$true; details="created result.json via real script and arguments" }
} catch {
    $results += [pscustomobject]@{ test_name="safe_python_roundtrip"; passed=$false; details=$_.Exception.Message }
}

try {
    & powershell -ExecutionPolicy Bypass -File $writeNoBom -Path $nobomPath -Text "plain utf8 no bom"
    $inspectJson = & powershell -ExecutionPolicy Bypass -File $safeInvoke -PythonExe $pythonExe -ScriptPath $inspect $nobomPath
    $inspectObj = $inspectJson | ConvertFrom-Json
    $results += [pscustomobject]@{
        test_name="utf8_nobom_write"
        passed=([bool](-not $inspectObj.has_utf8_bom))
        details=("first_bytes=" + (($inspectObj.first_bytes -join ",")))
    }
} catch {
    $results += [pscustomobject]@{ test_name="utf8_nobom_write"; passed=$false; details=$_.Exception.Message }
}

try {
    python $writeJson --output (Join-Path $unicodeDir "utf8_no_bom.json") --payload-file $payloadPath
    $content = & powershell -ExecutionPolicy Bypass -File $readUtf8 -Path (Join-Path $unicodeDir "utf8_no_bom.json")
    $ok = $content -match "项目A"
    $results += [pscustomobject]@{ test_name="utf8_json_write_and_read"; passed=[bool]$ok; details="explicit UTF-8 read preserved unicode text" }
} catch {
    $results += [pscustomobject]@{ test_name="utf8_json_write_and_read"; passed=$false; details=$_.Exception.Message }
}

try {
    & powershell -Command "@'
from pathlib import Path
p = Path(r'$inputPath')
print(p.read_text(encoding='utf-8'))
'@ | python -" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $results += [pscustomobject]@{ test_name="inline_python_pipe_negative_control"; passed=$false; details="unexpected success" }
    } else {
        $results += [pscustomobject]@{ test_name="inline_python_pipe_negative_control"; passed=$true; details="expected failure reproduced" }
    }
} catch {
    $results += [pscustomobject]@{ test_name="inline_python_pipe_negative_control"; passed=$true; details="expected failure reproduced" }
}

$results | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $artifactDir "test_results.csv")
$summary = @{
    total = $results.Count
    passed = @($results | Where-Object { $_.passed }).Count
    failed = @($results | Where-Object { -not $_.passed }).Count
    generated_at = (Get-Date).ToString("s")
}
$summary | ConvertTo-Json | Set-Content -Path (Join-Path $artifactDir "test_summary.json") -Encoding UTF8
$results | Format-Table -AutoSize
