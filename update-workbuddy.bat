@echo off
rem WorkBuddyGuide 一键更新部署脚本：拉取最新代码 + 更新依赖 + 重启本地服务
chcp 65001 >nul
cd /d "%~dp0"

echo [1/4] 拉取最新代码...
git pull
if errorlevel 1 (
    echo 拉取代码失败，请检查网络后重试。
    pause
    exit /b 1
)

echo [2/4] 更新依赖...
call npm install --no-fund --no-audit
if errorlevel 1 (
    echo 依赖更新失败。
    pause
    exit /b 1
)

echo [3/4] 停止旧的开发服务器（如有）...
set FOUND=0
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do (
    set FOUND=1
    echo   结束进程 PID %%a
    taskkill /PID %%a /F >nul 2>&1
)
if "%FOUND%"=="0" echo   未发现 5173 端口占用，无需停止。
timeout /t 2 /nobreak >nul

echo [4/4] 启动最新版开发服务器（Ctrl+C 可停止）...
call npm run dev
pause
