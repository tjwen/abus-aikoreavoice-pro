@echo off
setlocal enabledelayedexpansion

:: Check if we're running in SysWOW64
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if defined PROCESSOR_ARCHITEW6432 (
        :: We're running in 32-bit mode on a 64-bit system
        :: Re-launch using 64-bit cmd.exe
        %SystemRoot%\Sysnative\cmd.exe /c "%~dpnx0" %*
        exit /b
    )
)

:: At this point, we're running in 64-bit mode
:: Check if the script is being run directly or through another cmd instance
if /i "%~dp0"=="%SystemRoot%\SysWOW64\" (
    :: We're running from SysWOW64, re-launch using System32 cmd.exe
    %SystemRoot%\System32\cmd.exe /c "%~dpnx0" %*
    exit /b
)

echo =========================================================================
echo.
echo   ABUS Voice-Pro 更新工具 [版本 1.0]
echo.
echo =========================================================================
echo.

:: If we've reached here, we're running in the correct environment
echo 在System32中以64位模式运行
echo 当前目录: %CD%
echo 命令行: %*

cd /D "%~dp0"

:: 运行启动脚本，但添加--update参数
start python start-voice.py --update

echo 更新已启动，请稍候...
echo 完成后将自动关闭此窗口。

:: 等待一段时间后退出
timeout /t 5
exit