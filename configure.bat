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

:: run as admin
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)

echo =========================================================================
echo.
echo   ABUS Voice-Pro 配置工具 [版本 1.0]
echo.
echo =========================================================================
echo.

:: If we've reached here, we're running in the correct environment
:: Your actual batch file commands start here
echo 在System32中以64位模式运行
echo 当前目录: %CD%
echo 命令行: %*

:: LongPathsEnabled 值设置
echo 启用长路径支持...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
if %ERRORLEVEL% == 0 (
    echo 长路径已成功启用。
) else (
    echo 启用长路径失败。
    pause
    exit /b 1
)

cd /D "%~dp0"
SET "CHOCPATH=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe"
%CHOCPATH% -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: 检测NVIDIA GPU
set IS_NVIDIA_GPU=0
set "registry_path=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
set "search_key=DriverDesc"
for /f "tokens=2*" %%a in ('reg query "%registry_path%" /v "%search_key%" 2^>nul ^| findstr /i /c:"%search_key%"') do (
    set "value=%%b"
)

if not "!value!"=="" (
    echo 驱动描述: "!value!"
    set "substring=nvidia"
    echo "!value!" | findstr /I /C:"!substring!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo 检测到NVIDIA显卡
        set IS_NVIDIA_GPU=1
    ) else (
        set "substring=tesla"
        echo "!value!" | findstr /I /C:"!substring!" >nul 2>&1
        if !errorlevel! equ 0 (
            echo 检测到TESLA显卡
            set IS_NVIDIA_GPU=1
        )
    )
)

:: 安装CUDA
if !IS_NVIDIA_GPU! equ 1 (
    echo 检测到NVIDIA或TESLA GPU
    echo.
    choco install -y cuda --version=12.4.0
) else (
    echo 未检测到NVIDIA或TESLA GPU
    echo.
)

choco install -y git.install
choco install -y ffmpeg
choco install -y visualstudio2022buildtools --verbose
choco install -y visualstudio2022-workload-vctools --verbose

echo 配置完成。
pause

:: 重启系统
for /l %%i in (30,-1,1) do (
    cls
    echo.
    echo 配置完成。
    echo 系统将在%%i秒后重启。
    timeout /t 1 /nobreak >nul
)
shutdown /r /t 0