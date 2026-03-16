# Heartbeat / 心跳机制

> Prompt Optimizer Skill 的自动检查机制

---

## 快速开始

### 手动触发心跳

```bash
# Windows (PowerShell)
cd C:\Users\admin\.openclaw\workspace\skills\prompt-optimizer
.\heartbeat\check.bat

# 或
powershell -ExecutionPolicy Bypass -File heartbeat\check.ps1
```

### 预期输出

```
[Heartbeat] Starting checks...

========== Heartbeat Report ==========
Time: 2026/03/16 19:58:38

[Check 1] Rules file...
  [OK] Rules file: OK
[Check 2] Git repo...
  [OK] Git repo: OK
[Check 3] OpenClaw config...
  [OK] OpenClaw config: OK

Overall: ALL OK
======================================

[Heartbeat] Complete
```

---

## 检查项说明

| 检查项 | 说明 | 失败处理 |
|--------|------|----------|
| **Rules file** | 检查 `memory/agent-notes.md` 是否存在 | 重新安装 Skill |
| **Git repo** | 检查 Git 仓库状态 | 无需处理（仅提示） |
| **OpenClaw config** | 检查流式输出配置 | `openclaw config set channels.feishu.streaming true` |

---

## 自动执行（待实现）

### 方案 A：OpenClaw Cron

```json
// skill.json
{
  "heartbeat": {
    "enabled": true,
    "interval": "30m",
    "script": "heartbeat/check.bat"
  }
}
```

### 方案 B：Windows 任务计划程序

```bash
# 创建定时任务（每 30 分钟）
schtasks /Create /TN "PromptOptimizer Heartbeat" /TR "C:\Users\admin\.openclaw\workspace\skills\prompt-optimizer\heartbeat\check.bat" /SC MINUTE /MO 30
```

### 方案 C：用户会话触发

在每次与 AI 会话开始时自动执行心跳检查。

---

## 日志文件

**位置**：`memory/heartbeat-YYYY-MM-DD.md`

**格式**：
```markdown
# Heartbeat Log (2026-03-16)

| Time | Type | Status | Note |
|------|------|--------|------|
| 2026-03-16 19:58:38 | Standard | [OK] | Heartbeat OK |
```

---

## 故障排查

### 问题 1：脚本无法执行

**解决**：
```bash
# 检查执行策略
Get-ExecutionPolicy

# 如果为 Restricted，临时允许
powershell -ExecutionPolicy Bypass -File heartbeat\check.ps1
```

### 问题 2：日志文件未创建

**原因**：目录权限问题

**解决**：
```bash
# 检查目录权限
icacls "C:\Users\admin\.openclaw\workspace\memory"

# 或手动创建日志文件
echo "# Heartbeat Log" > memory\heartbeat-2026-03-16.md
```

### 问题 3：配置检查失败

**原因**：OpenClaw 未安装或配置错误

**解决**：
```bash
# 验证 OpenClaw 安装
openclaw --version

# 检查配置
openclaw config get channels.feishu.streaming
```

---

## 下一步计划

| 优先级 | 任务 | 状态 |
|--------|------|------|
| P0 | 基础检查脚本 | ✅ 已完成 |
| P1 | 日志记录修复 | ⏳ 待修复 |
| P1 | 自动调度集成 | ⏳ 待实现 |
| P2 | 用户报告界面 | ⏳ 待设计 |
| P2 | 深度心跳（备份/清理） | ⏳ 待设计 |

---

## 贡献

欢迎提交 Issue 或 PR 改进心跳机制！

**相关链接**：
- [Skill 主文档](../SKILL.md)
- [GitHub 仓库](https://github.com/liyu9/prompt-optimizer-skill)
