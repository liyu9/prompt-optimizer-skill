# Prompt 优化系统 Skill（V3.0）

> 让 AI 自动完成专业级 Prompt 重构，用户说人话即可

**版本**：V3.0  
**作者**：yu7  
**参考体系**：PromptPilot 工程化 Prompt 优化体系  
**适用平台**：OpenClaw + 飞书多 Agent 环境

---

## 技能介绍

本 Skill 实现了基于 PromptPilot 工程化体系的 Prompt 优化系统，让 AI 能够：
- 自动识别用户需求等级（L1-L4）
- 自动重构 Prompt（5 维度优化）
- 自动选择最匹配的 Agent
- 自动执行并返回结构化结果

**用户价值**：说人话即可，AI 自动完成专业级 Prompt 重构。

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

## 需求分级规则

| 等级 | 关键词 | 处理方式 | 示例 |
|------|--------|----------|------|
| **L1 简单** | 默认 | 直接执行 | "写一篇 300 字文章" |
| **L2 中等** | 调研/分析/设计/规划 | 展示优化思路 → 执行 | "调研一下竞品" |
| **L3 复杂** | 对比/选型/评审/架构 | 多 Agent 并行 → 对比 | "技术选型方案" |
| **L4 关键** | 客户/发布/对外/重要 | 显式确认 → 执行 | "生成客户方案 PPT" |

**关键词判断规则**：
- **L4**：包含"客户"、"发布"、"对外"、"重要"、"PPT"
- **L3**：包含"对比"、"选型"、"评审"、"架构"、"设计"
- **L2**：包含"调研"、"分析"、"规划"、"总结"
- **L1**：默认

---

## 角色使用规则

| 等级 | 是否加角色 | 示例角色 |
|------|-----------|----------|
| L1 简单 | ❌ 不加 | - |
| L2 调研/分析 | ✅ 加 | 产品经理/分析师 |
| L3 方案/选型 | ✅ 加 | 架构师/顾问 |
| L4 交付 | ✅ 加 | 资深顾问 |

**角色模板**：
```
你是 {年限} 年 {领域} 的{具体角色}，擅长{具体方向}
```

**示例**：
- "你是 5 年 B 端产品经理，擅长 CRM 设计"
- "你是资深技术架构师，擅长高并发系统设计"
- "你是行业分析师，擅长竞品调研"

---

## 回复格式模板

### L1 简单任务

```
【交付内容】
{content}
```

### L2-L3 中等/复杂任务

```
📋 原始需求：{user_input}
🎯 优化思路：{optimization_summary}
🤖 执行 Agent：{agent_name}
⏱️ 耗时：{duration}秒

【交付内容】
{content}
```

### L4 关键任务（确认阶段）

```
📋 原始需求：{user_input}

🎯 优化后的执行方案：
【任务】{task_description}
【维度】{dimensions}
【Agent】{agents}
【预计耗时】{duration}

请确认或修改：
- 回复"确认"立即执行
- 回复"补充 XXX"添加要求
- 回复"只要 XXX"简化范围

⏳ 等待确认...
```

---

## Agent 执行步骤

**其他 Agent 安装本 Skill 后，按以下步骤执行**：

### 步骤 1：加载规则

```
会话启动时自动读取 memory/agent-notes.md
```

**验证**：
```bash
# 检查规则是否加载
grep "需求分级" ~/.openclaw/workspace/memory/agent-notes.md
```

---

### 步骤 2：接收用户输入

```
接收用户消息 → 提取核心需求
```

---

### 步骤 3：判断任务等级

```python
# 伪代码
def classify_task(user_input):
    # L4 关键词
    l4_keywords = ["客户", "发布", "对外", "重要", "PPT"]
    if any(kw in user_input for kw in l4_keywords):
        return "L4"
    
    # L3 关键词
    l3_keywords = ["对比", "选型", "评审", "架构"]
    if any(kw in user_input for kw in l3_keywords):
        return "L3"
    
    # L2 关键词
    l2_keywords = ["调研", "分析", "规划", "总结"]
    if any(kw in user_input for kw in l2_keywords):
        return "L2"
    
    # 默认 L1
    return "L1"

task_level = classify_task(user_input)
```

---

### 步骤 4：Prompt 优化

```python
# 伪代码
def optimize_prompt(user_input, task_level):
    optimized = []
    
    # L2-L4 加角色
    if task_level in ["L2", "L3", "L4"]:
        role = get_role_for_task(user_input)
        optimized.append(f"【角色】你是{role}")
    
    optimized.append(f"【任务】{user_input}")
    
    # L2-L3 补充要求
    if task_level in ["L2", "L3"]:
        optimized.append("【要求】结构清晰，分维度分析")
        optimized.append("【输出】Markdown 格式，每个维度独立成段")
    
    # L4 补充确认
    if task_level == "L4":
        optimized.append("【确认】先输出方案框架，等待用户确认后再执行")
    
    return "\n".join(optimized)

optimized_prompt = optimize_prompt(user_input, task_level)
```

---

### 步骤 5：Agent 路由

```python
# 伪代码
def route_agent(task_level, task_type):
    # L4 任务：多 Agent 并行
    if task_level == "L4":
        return ["product-chief", "b2b-veteran", "ai-soldier"]
    
    # L3 任务：双 Agent 对比
    if task_level == "L3":
        if "技术" in task_type:
            return ["ai-soldier", "product-basic"]
        else:
            return ["product-chief", "b2b-veteran"]
    
    # L1-L2 任务：单 Agent
    agent_mapping = {
        "产品": "product-chief",
        "业务": "b2b-veteran",
        "技术": "ai-soldier",
        "文档": "product-basic",
    }
    
    for key, agent in agent_mapping.items():
        if key in task_type:
            return [agent]
    
    # 默认
    return ["xiaoxia"]

selected_agents = route_agent(task_level, extract_task_type(user_input))
```

---

### 步骤 6：执行前自检

```python
# 伪代码
def before_reply_check(task_level, optimized_prompt):
    checklist = {
        "task_level_classified": True,
        "optimization_summary_prepared": task_level in ["L2", "L3"],
        "confirmation_required": task_level == "L4",
        "role_added": task_level in ["L2", "L3", "L4"] and "【角色】" in optimized_prompt,
    }
    
    if not all(checklist.values()):
        log_error("自检未通过", checklist)
        return False
    
    return True
```

---

### 步骤 7：执行并返回

```python
# 伪代码
def execute(selected_agents, optimized_prompt):
    if len(selected_agents) == 1:
        # 单 Agent 执行
        result = call_agent(selected_agents[0], optimized_prompt)
        return format_single_output(result)
    else:
        # 多 Agent 并行
        results = parallel_call_agents(selected_agents, optimized_prompt)
        return format_comparison_output(results)

final_output = execute(selected_agents, optimized_prompt)
send_message(final_output)
```

---

### 步骤 8：回复后验证

```python
# 伪代码
def after_reply_check(reply_content, task_level):
    violations = []
    
    # L2-L3 必须展示优化思路
    if task_level in ["L2", "L3"]:
        if "🎯 优化思路" not in reply_content:
            violations.append("L2-L3 未展示优化思路")
    
    # L4 必须显式确认
    if task_level == "L4":
        if "请确认" not in reply_content:
            violations.append("L4 未请求确认")
    
    if violations:
        log_violation(violations)
        auto_append_correction(violations)
    
    return len(violations) == 0
```

---

## 配置要求

| 配置项 | 要求 | 验证命令 |
|--------|------|----------|
| OpenClaw | ≥ 2026.3.8 | `openclaw --version` |
| 记忆系统 | 已启用 | `ls memory/` |

**可选配置**（飞书环境）：
| 配置项 | 要求 | 验证命令 |
|--------|------|----------|
| 飞书插件 | ≥ 1.2.0 | `openclaw plugins list` |
| 流式输出 | 已开启 | `openclaw config get channels.feishu.streaming` |

---

## 测试用例

| 等级 | 输入 | 预期输出 |
|------|------|----------|
| L1 | "写一篇 300 字文章" | 直接执行，无优化思路 |
| L2 | "调研一下竞品" | 展示🎯优化思路 + 执行 |
| L3 | "技术选型方案" | 展示🎯优化思路 + 多 Agent 对比 |
| L4 | "生成客户方案 PPT" | 显式确认方案 |

---

## 完整文档

- 系统设计文档：联系作者获取
- GitHub 仓库：https://github.com/liyu9/prompt-optimizer-skill

---

## License

MIT License
