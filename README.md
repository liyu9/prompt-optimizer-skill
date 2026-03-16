# Prompt 优化系统 Skill

> 让 AI 自动完成专业级 Prompt 重构，用户说人话即可

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://clawhub.ai/skills/prompt-optimizer-100)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-%3E%3D2026.3.8-green.svg)](https://openclaw.ai)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 技能介绍

本 Skill 基于 PromptPilot 工程化 Prompt 优化体系，实现 AI 自动完成专业级 Prompt 重构。

**核心价值**：用户说人话即可，AI 后台自动完成：
- 需求等级判断（L1-L4）
- Prompt 5 维度优化（角色/背景/任务/约束/示例）
- Agent 智能路由
- 结构化结果返回

---

## 核心功能

| 功能 | 说明 |
|------|------|
| **需求分级** | 自动判断 L1-L4 任务等级（关键词匹配） |
| **Prompt 优化** | 5 维度重构（角色/背景/任务/约束/示例） |
| **Agent 路由** | 单 Agent / 多 Agent 并行 |
| **执行保障** | 自检清单 + Badcase 闭环 |
| **Merge 模式** | 保留用户原有规则，增量更新 |

---

## 需求分级

| 等级 | 关键词 | 处理方式 |
|------|--------|----------|
| L1 | 默认 | 直接执行 |
| L2 | 调研/分析/设计 | 展示优化思路 → 执行 |
| L3 | 对比/选型/评审 | 多 Agent 并行 → 对比 |
| L4 | 客户/发布/对外 | 显式确认 → 执行 |

---

## 文档

| 文档 | 链接 |
|------|------|
| 完整设计文档 | https://feishu.cn/docx/He9Gdnpd4oTydyxSAZYcVQ1dnTc |
| GitHub 仓库 | https://github.com/liyu9/prompt-optimizer-skill |
| clawhub.ai | https://clawhub.ai/skills/prompt-optimizer-100 |

---

## License

MIT License
