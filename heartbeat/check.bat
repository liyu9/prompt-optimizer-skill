@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo [Heartbeat] Starting checks...

set "WORKSPACE=%USERPROFILE%\.openclaw\workspace"
set "MEMORY=%WORKSPACE%\memory"
set "LOGFILE=%MEMORY%\heartbeat-%date:~0,4%-%date:~5,2%-%date:~8,2%.md"
set "STATUS=ok"

echo.
echo ========== Heartbeat Report ==========
echo Time: %date% %time%
echo.

REM Check 1: Rules file
echo [Check 1] Rules file...
if exist "%MEMORY%\agent-notes.md" (
    echo   [OK] Rules file: OK
) else (
    echo   [ERROR] Rules file: MISSING
    set "STATUS=warning"
)

REM Check 2: Git repo
echo [Check 2] Git repo...
if exist "%WORKSPACE%\skills\prompt-optimizer\.git" (
    echo   [OK] Git repo: OK
) else (
    echo   [INFO] Not a Git repo, skip
)

REM Check 3: OpenClaw config
echo [Check 3] OpenClaw config...
openclaw config get channels.feishu.streaming >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] OpenClaw config: OK
) else (
    echo   [WARN] Cannot read config
    set "STATUS=warning"
)

echo.
if "%STATUS%"=="ok" (
    echo Overall: ALL OK
) else (
    echo Overall: ISSUES DETECTED
)
echo ======================================
echo.

REM Log heartbeat
echo | set /p dummy=| %date% %time% | Standard | [%STATUS%] | Heartbeat OK | >> "%LOGFILE%" 2>nul
if errorlevel 1 (
    echo [WARN] Log save failed
) else (
    echo [Log] Saved to: %LOGFILE%
)

echo.
echo [Heartbeat] Complete
pause
