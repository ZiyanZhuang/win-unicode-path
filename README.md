# Windows Unicode Path Ops

这是一个面向 **Windows + PowerShell 5.1 + Python + 中文路径** 场景的公开分享包，目标是减少非 ASCII 路径导致的：

- 中文路径显示乱码
- 路径被替换成 `??`
- Python 或其他原生命令报 `OSError: [Errno 22] Invalid argument`

这个仓库包含：

- 一个可复用的 Codex skill
- 一组 PowerShell / Python helper 脚本
- 一套脱敏测试用例
- 一组脱敏后的定量指标

适合的用户包括：

- 在 Windows 上使用 PowerShell 5.1 的开发者
- 经常处理中文目录、日文目录、韩文目录或其他 Unicode 路径的用户
- 使用 Codex、CLI、Python 脚本、自动化任务时频繁遇到路径乱码的人

## 这个仓库解决什么问题

在 Windows 下，和 Unicode 路径相关的问题通常分成两类：

### 1. 显示层乱码

典型现象：

- `实验` 显示成乱码字符串

本质原因：

- UTF-8 文件被按 GBK / CP936 解码

特点：

- 文件本身未必坏了
- 但日志、JSON、终端输出会误导排查

### 2. 执行层路径损坏

典型现象：

- 原始路径是 `E:\demo\项目A\data.txt`
- 传到 Python 后变成 `E:\??\data.txt`

本质原因：

- PowerShell 5.1 把包含非 ASCII 字符的文本，通过错误编码送进原生进程

特点：

- 这不是“看起来乱码”
- 而是真正把路径破坏掉了
- 很容易直接报错并中断流程

本仓库主要解决第二类问题，同时也帮助第一类问题更快定位。

## 仓库结构

- `skill/`
  可直接复用的 skill，本体、references、helper 脚本都在这里。

- `tests/`
  可执行测试，运行时会创建临时 Unicode 路径并验证安全模式和危险模式。

- `metrics/`
  脱敏后的统计数据，包括历史排查计数、环境画像、测试结果。

- `scripts/`
  仓库级辅助脚本。

## 包含的 helper

### 1. `skill/scripts/invoke_python_utf8_safe.ps1`

用途：

- 用安全方式从 PowerShell 启动 Python 文件脚本
- 避免使用 `@' ... '@ | python -` 这种高风险模式

适合场景：

- 中文路径作为 Python 参数传入
- PowerShell 调度 Python 任务
- 需要稳定处理 Unicode 输入路径和输出路径

### 2. `skill/scripts/read_utf8_text.ps1`

用途：

- 在 PowerShell 5.1 中显式按 UTF-8 读取文本文件

适合场景：

- 读取 UTF-8 JSON
- 读取 UTF-8 日志
- 避免默认编码导致的误读

### 3. `skill/scripts/write_json_utf8.py`

用途：

- 用显式 UTF-8 写 JSON
- 支持 `--payload` 和 `--payload-file`

适合场景：

- 想稳定输出 UTF-8 JSON
- 想在 Windows 上避免 shell 转义干扰

### 4. `skill/scripts/write_utf8_nobom_text.ps1`

用途：

- 写出 **UTF-8 无 BOM** 的纯文本文件

适合场景：

- 需要避免 PowerShell 5.1 默认 BOM 行为
- 想控制文本文件首字节

## 推荐用法

### 不推荐

```powershell
@'
from pathlib import Path
Path(r'E:\demo\项目A\data.txt').read_text(encoding='utf-8')
'@ | python -
```

这种写法在 Windows PowerShell 5.1 下很容易把路径破坏成 `??`。

### 推荐

```powershell
powershell -ExecutionPolicy Bypass -File .\skill\scripts\invoke_python_utf8_safe.ps1 `
  -PythonExe E:\conda\envs_dirs\ezs_env\python.exe `
  -ScriptPath .\tests\scripts\echo_path_roundtrip.py `
  E:\demo\项目A\data.txt `
  E:\demo\项目A\result.json
```

## 如何运行测试

在 PowerShell 中执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\run_tests.ps1
```

测试输出：

- `tests/artifacts/test_results.csv`
- `tests/artifacts/test_summary.json`

当前测试覆盖：

1. 安全 Python round-trip
2. UTF-8 无 BOM 文本写入
3. UTF-8 JSON 写入与显式读取
4. inline Python pipe 负对照

其中第 4 项的目标是：

- **故意复现错误**
- 并确认它确实是一个危险模式

因此“预期失败被成功复现”应当被视为测试通过。

## 定量指标说明

### `metrics/incident_counts.csv`

这里放的是脱敏后的历史调查统计，例如：

- 稳定乱码标记出现次数
- `??` / `Invalid argument` 类路径损坏痕迹次数
- 广义路径相关匹配次数

这些数字用于说明：

- 这不是偶发 bug
- 而是结构性问题

### `metrics/environment_profile.csv`

这里记录的是造成问题的典型环境特征，例如：

- PowerShell 版本
- 当前代码页
- 默认文本编码
- `$OutputEncoding`

### `metrics/test_results.csv`

这里记录仓库自带测试的执行结果。

## 脱敏说明

本仓库已经做了信息脱敏处理：

- 不包含真实用户名
- 不包含真实学校、机构或项目名
- 不包含真实 OneDrive 路径
- 不包含本机上的私有目录结构

测试运行时使用的是通用 Unicode 目录名，而不是用户私有路径。

## 适合分享到 GitHub 的原因

这个仓库已经具备公开分享所需的基本要素：

- 中文 README
- 明确的问题定义
- 可执行 helper
- 可执行测试
- 脱敏后的数据

如果你想继续完善，可以继续增加：

- 英文 README
- GitHub Actions Windows 测试
- 更多语言路径样例（如日文、韩文、emoji）
- 针对 PowerShell 7 的对照测试
