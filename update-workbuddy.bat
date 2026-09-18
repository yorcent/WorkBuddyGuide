@echo off
rem WorkBuddyGuide 一键同步更新脚本：同步上游仓库 + 推送自己的 fork + 更新依赖 + 重启本地服务
chcp 65001 >nul
cd /d "%~dp0"

echo [1/5] 检查工作区状态...
git status --porcelain | findstr /r /c:"." >nul
if not errorlevel 1 (
    echo   工作区有未提交的改动，请先提交或暂存后再同步。
    echo   （git status 可查看改动清单）
    git status --short
    pause
    exit /b 1
)
echo   工作区干净，继续。

echo [2/5] 拉取上游仓库（AlephAITech/WorkBuddyGuide）最新内容...
git fetch upstream
if errorlevel 1 (
    echo   拉取上游失败，请检查网络连接后重试。
    pause
    exit /b 1
)

echo [3/5] 合并上游 main 到本地...
git merge upstream/main --no-edit
if errorlevel 1 (
    echo   合并冲突！请先手动解决：
    echo     git status 查看冲突文件，编辑解决后执行 git add 与 git commit
    pause
    exit /b 1
)

echo [4/5] 推送到你的 fork（yorcent/WorkBuddyGuide）...
git push origin main
if errorlevel 1 (
    echo   推送失败（可能未登录 GitHub）。本地已同步，可稍后执行 git push origin main
)

echo [5/5] 更新依赖并重启本地服务...
call npm install --no-fund --no-audit
if errorlevel 1 (
    echo   依赖更新失败。
    pause
    exit /b 1
)

echo   停止旧的开发服务器（如有）...
set FOUND=0
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do (
    set FOUND=1
    echo   结束进程 PID %%a
    taskkill /PID %%a /F >nul 2>&1
)
if "%FOUND%"=="0" echo   未发现 5173 端口占用，无需停止。
timeout /t 2 /nobreak >nul

echo 启动最新版开发服务器（Ctrl+C 可停止）...
call npm run dev
pause
