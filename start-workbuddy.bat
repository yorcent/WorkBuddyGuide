@echo off
rem WorkBuddyGuide 本地开发服务器一键启动脚本
cd /d "%~dp0"
echo Starting WorkBuddyGuide dev server at http://127.0.0.1:5173/
call npm run dev
pause
