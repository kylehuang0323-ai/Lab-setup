@echo off
REM ================================================================
REM  GMK EVO-X2 一键驱动安装脚本 (I-Lab)
REM  驱动包: AXB35_02_Win11_24H2_Driver_list_V007
REM  用法: 以管理员身份运行此脚本
REM  来源: NAS \\192.168.0.81\Software\AXB35_02_Win11_24H2_Driver_list_V007
REM ================================================================

REM === 请求管理员权限 ===
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] 请求管理员权限...
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b 0
)

cd /d %~dp0
setlocal EnableDelayedExpansion

REM === 配置 ===
set "LOGFILE=%~dp0DriverInstall_%date:~0,4%%date:~5,2%%date:~8,2%.log"
set PASS_COUNT=0
set FAIL_COUNT=0
set TOTAL=10

echo ================================================================
echo   GMK EVO-X2 (AXB35) 驱动一键安装
echo   驱动包版本: V007 / Windows 11 24H2
echo   日志文件: %LOGFILE%
echo ================================================================
echo.
echo [%date% %time%] 开始安装驱动... >> "%LOGFILE%"

REM === 01: AMD 芯片组 ===
call :InstallDriver "01_AMD_Chipset_7.04.30.030" "Install.bat" "AMD Chipset"

REM === 02: AMD 显卡 ===
call :InstallDriver "02_AMD_Graphics_24.20.64" "Install.bat" "AMD Graphics (iGPU)"

REM === 03: 声卡 ===
call :InstallDriver "03_Senary_Audio_4.18.0.4" "Install.bat" "Senary Audio"

REM === 04: WiFi ===
call :InstallDriver "04_AMD_WiFi_5.5.0.3760" "wifiInstall.bat" "AMD WiFi"

REM === 05: 蓝牙 ===
call :InstallDriver "05_AMD_BT_1.1042.0.527" "BTInstall.bat" "AMD Bluetooth"

REM === 06: 有线网卡 ===
call :InstallDriver "06_Lan_1125.021.0903.2024" "Install.bat" "Realtek LAN"

REM === 07: 读卡器 ===
call :InstallDriver "07_Cardreader_1.1.49.0" "Install.bat" "Card Reader"

REM === 08: ACP (AMD Control Platform) ===
call :InstallDriver "08_ACP_7.0.0.44" "install.bat" "AMD ACP"

REM === 09: 摄像头 ===
call :InstallDriver "09_Camera_11.4.2.629" "install.bat" "Camera"

REM === 10: Radeon Software (AMD 显卡管理软件) ===
call :InstallDriver "10_AMD_radeonsoftware_14.0.33728.0" "Appinstall.bat" "Radeon Software"

REM === 安装完成汇总 ===
echo.
echo ================================================================
echo   安装完成！
echo   成功: %PASS_COUNT% / %TOTAL%
echo   失败: %FAIL_COUNT% / %TOTAL%
echo   日志: %LOGFILE%
echo ================================================================
echo.
echo [%date% %time%] 安装完成 - 成功:%PASS_COUNT% 失败:%FAIL_COUNT% >> "%LOGFILE%"

if %FAIL_COUNT% GTR 0 (
    echo [警告] 有 %FAIL_COUNT% 个驱动安装失败，请检查日志文件。
    echo.
)

echo 建议安装完成后重启计算机。
echo.
pause
exit /b 0

REM ================================================================
REM  子程序: 安装单个驱动
REM  参数: %1=文件夹名 %2=安装脚本名 %3=驱动显示名称
REM ================================================================
:InstallDriver
set "FOLDER=%~1"
set "SCRIPT=%~2"
set "NAME=%~3"

echo [%time%] 正在安装: %NAME% ...
echo [%date% %time%] Installing: %NAME% (%FOLDER%\%SCRIPT%) >> "%LOGFILE%"

if not exist "%~dp0%FOLDER%\%SCRIPT%" (
    echo   [跳过] 未找到 %FOLDER%\%SCRIPT%
    echo [%date% %time%] SKIP - File not found: %FOLDER%\%SCRIPT% >> "%LOGFILE%"
    goto :eof
)

pushd "%~dp0%FOLDER%"

REM 检查是否有 WHQL 签名确认
if exist "source\Click_WHQL\WHQL_Click.cmd" (
    call "source\Click_WHQL\WHQL_Click.cmd" >nul 2>&1
)

call "%SCRIPT%" >nul 2>&1
if !errorlevel! NEQ 0 (
    echo   [失败] %NAME% (错误码: !errorlevel!)
    echo [%date% %time%] FAIL - %NAME% errorlevel=!errorlevel! >> "%LOGFILE%"
    set /a FAIL_COUNT+=1
) else (
    echo   [成功] %NAME%
    echo [%date% %time%] PASS - %NAME% >> "%LOGFILE%"
    set /a PASS_COUNT+=1
)

popd
timeout /t 2 /nobreak >nul
goto :eof
