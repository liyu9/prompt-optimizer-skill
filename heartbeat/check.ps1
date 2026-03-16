# OpenClaw Prompt Optimizer 心跳检查脚本
# 用法：.\heartbeat\check.ps1

param(
    [switch]$Verbose,
    [switch]$Report
)

$ErrorActionPreference = "Stop"
$WorkspacePath = "$env:USERPROFILE\.openclaw\workspace"
$MemoryPath = "$WorkspacePath\memory"
$LogPath = "$MemoryPath\heartbeat-$(Get-Date -Format 'yyyy-MM-dd').md"

Write-Host "[Heartbeat] Starting checks..." -ForegroundColor Cyan

# 初始化检查结果
$Results = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Checks = @{}
    Status = "ok"
}

# 检查 1：规则文件是否存在
Write-Host "[Check 1] Rules file..." -ForegroundColor Gray
$RulesPath = "$MemoryPath\agent-notes.md"
if (Test-Path $RulesPath) {
    $Results.Checks["rules"] = @{ Status = "ok"; Message = "Rules file exists" }
    Write-Host "  [OK] Rules file: OK" -ForegroundColor Green
} else {
    $Results.Checks["rules"] = @{ Status = "error"; Message = "Rules file missing" }
    Write-Host "  [ERROR] Rules file: MISSING" -ForegroundColor Red
    $Results.Status = "warning"
}

# 检查 2：编辑冲突（检查最近 Git 提交）
Write-Host "[Check 2] Edit conflicts..." -ForegroundColor Gray
try {
    $GitPath = "$WorkspacePath\skills\prompt-optimizer"
    if (Test-Path "$GitPath\.git") {
        $RecentCommits = & git -C $GitPath log --oneline --since="30 minutes ago" 2>$null
        $ConflictCommits = $RecentCommits | Where-Object { $_ -match "conflict" }
        $ConflictCount = @($ConflictCommits).Count
        
        if ($ConflictCount -gt 3) {
            $Results.Checks["conflicts"] = @{ Status = "warning"; Message = "$ConflictCount conflicts in 30min" }
            Write-Host "  [WARN] Conflicts: $ConflictCount" -ForegroundColor Yellow
            $Results.Status = "warning"
        } else {
            $Results.Checks["conflicts"] = @{ Status = "ok"; Message = "$ConflictCount conflicts in 30min" }
            Write-Host "  [OK] Conflicts: $ConflictCount" -ForegroundColor Green
        }
    } else {
        $Results.Checks["conflicts"] = @{ Status = "ok"; Message = "Not a Git repo" }
        Write-Host "  [INFO] Not a Git repo, skip" -ForegroundColor Gray
    }
} catch {
    $Results.Checks["conflicts"] = @{ Status = "ok"; Message = "Cannot check Git" }
    Write-Host "  [INFO] Cannot check Git status" -ForegroundColor Gray
}

# 检查 3：OpenClaw 配置
Write-Host "[Check 3] OpenClaw config..." -ForegroundColor Gray
try {
    $StreamingConfig = & openclaw config get channels.feishu.streaming 2>$null | Out-String
    if ($StreamingConfig -match "true") {
        $Results.Checks["config"] = @{ Status = "ok"; Message = "Streaming enabled" }
        Write-Host "  [OK] Streaming: Enabled" -ForegroundColor Green
    } else {
        $Results.Checks["config"] = @{ Status = "warning"; Message = "Streaming not enabled" }
        Write-Host "  [WARN] Streaming: Not enabled" -ForegroundColor Yellow
        $Results.Status = "warning"
    }
} catch {
    $Results.Checks["config"] = @{ Status = "error"; Message = "Cannot read config" }
    Write-Host "  [ERROR] Cannot read config" -ForegroundColor Red
    $Results.Status = "warning"
}

# 生成报告
Write-Host ""
Write-Host "========== Heartbeat Report ==========" -ForegroundColor Cyan
Write-Host "Time: $($Results.Timestamp)"
Write-Host ""

foreach ($check in $Results.Checks.GetEnumerator()) {
    $Icon = if ($check.Value.Status -eq "ok") { "[OK]" } elseif ($check.Value.Status -eq "warning") { "[WARN]" } else { "[ERROR]" }
    Write-Host "$Icon $($check.Key): $($check.Value.Message)"
}

Write-Host ""
$OverallStatus = if ($Results.Status -eq "ok") { "ALL OK" } else { "ISSUES DETECTED" }
Write-Host "Overall: $OverallStatus" -ForegroundColor $(if ($Results.Status -eq "ok") { "Green" } else { "Yellow" })
Write-Host "======================================" -ForegroundColor Cyan

# 记录日志
try {
    if (-not (Test-Path $LogPath)) {
        @"
# Heartbeat Log ($(Get-Date -Format 'yyyy-MM-dd'))

| Time | Type | Status | Note |
|------|------|--------|------|
"@ | Out-File $LogPath -Encoding UTF8
    }
    
    $StatusIcon = if ($Results.Status -eq "ok") { "[OK]" } else { "[WARN]" }
    "| $($Results.Timestamp) | Standard | $StatusIcon | Heartbeat OK |`n" | Out-File $LogPath -Encoding UTF8 -Append
    
    Write-Host "[Log] Saved to: $LogPath" -ForegroundColor Gray
} catch {
    Write-Host "[WARN] Log save failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 如有问题，提示用户
if ($Results.Status -eq "warning") {
    Write-Host ""
    Write-Host "[WARN] Issues detected, please check above warnings" -ForegroundColor Yellow
    if ($Report) {
        Write-Host ""
        Write-Host "Full report displayed above" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "[Heartbeat] Complete" -ForegroundColor Cyan

# 返回结果（用于脚本调用）
return $Results
