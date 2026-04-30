---
name: windows-unicode-path-ops
description: Use when working on Windows with non-ASCII paths such as Chinese, Japanese, Korean, emoji, or accented characters, especially when tasks involve PowerShell 5.1, Python, inline scripts, JSON or log files, UTF-8 versus GBK decoding, or path corruption into question marks.
---

# Windows Unicode Path Ops

## Overview

Use this skill to avoid and diagnose Windows path failures caused by encoding mismatches.

This skill is the default guardrail when:
- paths contain Chinese or other non-ASCII characters
- PowerShell 5.1 is involved
- Python is launched from PowerShell
- UTF-8 files are being read or written
- logs or JSON show mojibake
- native commands receive `??` instead of the real path

## Trigger Signals

Strong triggers include:
- Chinese path
- unicode path
- non-ascii path
- mojibake
- UTF-8
- GBK
- CP936
- PowerShell 5.1
- path becomes question marks
- `Invalid argument`
- `??`

## Core Diagnosis

Treat these as two different failure classes:

1. Display-layer corruption
- A UTF-8 file was decoded as GBK or CP936.
- The path may still be valid.

2. Execution-layer corruption
- PowerShell or another native boundary converted a real non-ASCII path into `??`.
- The path is no longer valid.

Do not confuse these two cases.

## Hard Rules

### 1. Avoid inline Python for non-ASCII paths

Do not default to:

```powershell
@'
...python code with non-ascii paths...
'@ | python -
```

Prefer a real `.py` file in an ASCII-safe directory plus explicit arguments.

### 2. Use explicit UTF-8 reads in PowerShell

When reading UTF-8 files in PowerShell, use:
- `Get-Content -Encoding UTF8`
- `Set-Content -Encoding utf8`
- `Out-File -Encoding utf8`

### 3. Set a UTF-8 preamble before native commands

Before running Python or other native programs from PowerShell, set:

```powershell
[Console]::InputEncoding  = [Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
chcp 65001 > $null
$env:PYTHONUTF8 = '1'
$env:PYTHONIOENCODING = 'utf-8'
```

Use the bundled helper script instead of rewriting this by hand.

### 4. Prefer arguments over piped source text

Pass paths as command arguments to a script file.

### 5. Distinguish logging from execution

If the task only needs stable logs or JSON, escaped output can be acceptable.

If the task needs file access, preserve the real Unicode path end-to-end.

## Helper Scripts

- `scripts/invoke_python_utf8_safe.ps1`
- `scripts/read_utf8_text.ps1`
- `scripts/write_json_utf8.py`
- `scripts/write_utf8_nobom_text.ps1`

## References

- `references/failure-modes.md`
- `references/safe-patterns.md`
