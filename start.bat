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
echo   ABUS Voice-Pro 启动器 [版本 1.0]
echo.
echo =========================================================================
echo.

:: If we've reached here, we're running in the correct environment
:: Your actual batch file commands start here
echo 在System32中以64位模式运行
echo 当前目录: %CD%
echo 命令行: %*

cd /D "%~dp0"
set PATH=%PATH%;%SystemRoot%\system32
echo "%CD%"| findstr /C:" " >nul && echo 此脚本依赖于Miniconda，无法在包含空格的路径下静默安装。 && goto end

:: 检查安装路径中的特殊字符
set "SPCHARMESSAGE="警告：在安装路径中检测到特殊字符！" "         这可能导致安装失败！""
echo "%CD%"| findstr /R /C:"[!#\$%%&()\*+,;<=>?@\[\]\^`{|}~]" >nul && (
	call :PrintBigMessage %SPCHARMESSAGE%
)
set SPCHARMESSAGE=

:: 修复当安装到单独驱动器时的失败
set TMP=%cd%\installer_files
set TEMP=%cd%\installer_files

:: 根据需要取消激活已存在的conda环境以避免冲突
(call conda deactivate && call conda deactivate && call conda deactivate) 2>nul

:: 配置
set INSTALL_DIR=%cd%\installer_files
set CONDA_ROOT_PREFIX=%cd%\installer_files\conda
set INSTALL_ENV_DIR=%cd%\installer_files\env

:: ABUS miniconda for python 3.10
set MINICONDA_DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py310_24.5.0-0-Windows-x86_64.exe
set MINICONDA_CHECKSUM=978114c55284286957be2341ad0090eb5287222183e895bab437c4d1041a0284
set conda_exists=F

:: 判断是否需要安装git和conda
call "%CONDA_ROOT_PREFIX%\_conda.exe" --version >nul 2>&1
if "%ERRORLEVEL%" EQU "0" set conda_exists=T

:: (如有必要)将git和conda安装到独立环境中
:: 下载conda
if "%conda_exists%" == "F" (
	echo 正在从 %MINICONDA_DOWNLOAD_URL% 下载Miniconda到 %INSTALL_DIR%\miniconda_installer.exe

	mkdir "%INSTALL_DIR%"
	call curl -Lk "%MINICONDA_DOWNLOAD_URL%" > "%INSTALL_DIR%\miniconda_installer.exe" || ( echo. && echo Miniconda下载失败。 && goto end )

	for /f %%a in ('CertUtil -hashfile "%INSTALL_DIR%\miniconda_installer.exe" SHA256 ^| find /i /v " " ^| find /i "%MINICONDA_CHECKSUM%"') do (
		set "output=%%a"
	)

	if not defined output (
		echo miniconda_installer.exe的校验和验证失败。
		del "%INSTALL_DIR%\miniconda_installer.exe"
		goto end
	) else (
		echo miniconda_installer.exe的校验和验证成功通过。
	)

	echo 正在安装Miniconda到 %CONDA_ROOT_PREFIX%
	start /wait "" "%INSTALL_DIR%\miniconda_installer.exe" /InstallationType=JustMe /NoShortcuts=1 /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=%CONDA_ROOT_PREFIX%

	:: 测试conda二进制文件
	echo Miniconda版本:
	call "%CONDA_ROOT_PREFIX%\_conda.exe" --version || ( echo. && echo 未找到Miniconda。 && goto end )

	:: 删除Miniconda安装程序
	del "%INSTALL_DIR%\miniconda_installer.exe"
)

:: ABUS python 3.10 - 创建安装环境
set abus_genuine_installed=T
if not exist "%INSTALL_ENV_DIR%" (
	set abus_genuine_installed=F
	echo 要安装的包: %PACKAGES_TO_INSTALL%
	call "%CONDA_ROOT_PREFIX%\_conda.exe" create --no-shortcuts -y -k --prefix "%INSTALL_ENV_DIR%" python=3.10 || ( echo. && echo Conda环境创建失败。 && goto end )
)

:: 检查conda环境是否真正创建
if not exist "%INSTALL_ENV_DIR%\python.exe" ( echo. && echo Conda环境为空。 && goto end )

:: 环境隔离
set PYTHONNOUSERSITE=1
set PYTHONPATH=
set PYTHONHOME=
set "CUDA_PATH=%INSTALL_ENV_DIR%"
set "CUDA_HOME=%CUDA_PATH%"

:: 激活安装环境
call "%CONDA_ROOT_PREFIX%\condabin\conda.bat" activate "%INSTALL_ENV_DIR%" || ( echo. && echo 未找到Miniconda钩子。 && goto end )

:: 设置安装环境
echo Miniconda位置: %CONDA_ROOT_PREFIX%
cd /D "%~dp0"
if "%abus_genuine_installed%" == "F" (
	call python -m pip install huggingface-hub==0.27.1
)

set LOG_LEVEL=DEBUG
call python start-voice.py

:: 以下是脚本的函数 下一行在正常执行期间跳过这些
goto end

:PrintBigMessage
echo. && echo.
echo *******************************************************************
for %%M in (%*) do echo * %%~M
echo *******************************************************************
echo. && echo.
exit /b

:end
pause