# Safe Patterns

## Safe Python launch from PowerShell

Preferred:

```powershell
powershell -ExecutionPolicy Bypass -File .\skill\scripts\invoke_python_utf8_safe.ps1 `
  -PythonExe E:\conda\envs_dirs\ezs_env\python.exe `
  -ScriptPath .\tests\scripts\echo_path_roundtrip.py `
  E:\demo\项目A\data.txt `
  E:\demo\项目A\result.json
```

Avoid:

```powershell
@'
from pathlib import Path
Path(r'E:\demo\项目A\data.txt').read_text()
'@ | python -
```

## Safe UTF-8 read in PowerShell

```powershell
Get-Content -Encoding UTF8 E:\demo\项目A\result.json
```

## Safe UTF-8 no-BOM text write in PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\skill\scripts\write_utf8_nobom_text.ps1 `
  -Path E:\demo\项目A\notes.txt `
  -Text "example"
```
