@echo off
REM Appium 环境自动安装脚本 (Windows)
REM 用法: install_appium.bat

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Appium 环境自动安装脚本 (Windows)
echo ========================================
echo.

REM 检查是否以管理员权限运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [警告] 建议以管理员身份运行此脚本
    echo.
)

REM 确认继续
echo 此脚本将安装以下组件:
echo   - Node.js 和 npm ^(如果未安装^)
echo   - Appium Server 和 Appium Doctor
echo   - Python 依赖包 ^(从 requirements.txt^)
echo   - UIAutomator2 驱动
echo.
set /p CONFIRM="是否继续? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo 安装已取消
    exit /b 0
)

echo.
echo ========================================
echo   检查 Node.js 和 npm
echo ========================================
echo.

REM 检查 Node.js
where node >nul 2>&1
if %errorLevel% equ 0 (
    echo [成功] Node.js 已安装
    node --version
) else (
    echo [错误] Node.js 未安装
    echo.
    echo 请手动安装 Node.js:
    echo   1. 访问 https://nodejs.org/
    echo   2. 下载 LTS 版本
    echo   3. 安装时勾选 "Add to PATH"
    echo   4. 安装完成后重新运行此脚本
    echo.
    pause
    exit /b 1
)

REM 检查 npm
where npm >nul 2>&1
if %errorLevel% equ 0 (
    echo [成功] npm 已安装
    npm --version
) else (
    echo [错误] npm 未安装，请重新安装 Node.js
    pause
    exit /b 1
)

echo.
echo ========================================
echo   安装 Appium Server
echo ========================================
echo.

REM 检查 Appium 是否已安装
where appium >nul 2>&1
if %errorLevel% equ 0 (
    echo [成功] Appium Server 已安装
    appium -v
) else (
    echo [信息] 正在安装 Appium Server...
    call npm install -g appium
    
    where appium >nul 2>&1
    if %errorLevel% equ 0 (
        echo [成功] Appium Server 安装成功
        appium -v
    ) else (
        echo [错误] Appium Server 安装失败
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   安装 Appium Doctor
echo ========================================
echo.

REM 检查 Appium Doctor
where appium-doctor >nul 2>&1
if %errorLevel% equ 0 (
    echo [成功] Appium Doctor 已安装
) else (
    echo [信息] 正在安装 Appium Doctor...
    call npm install -g appium-doctor
    
    where appium-doctor >nul 2>&1
    if %errorLevel% equ 0 (
        echo [成功] Appium Doctor 安装成功
    ) else (
        echo [警告] Appium Doctor 安装失败 ^(可选工具^)
    )
)

echo.
echo ========================================
echo   安装 UIAutomator2 驱动
echo ========================================
echo.

echo [信息] 正在安装 UIAutomator2 驱动...
call appium driver install uiautomator2
if %errorLevel% equ 0 (
    echo [成功] UIAutomator2 驱动安装成功
) else (
    echo [警告] UIAutomator2 驱动安装失败
)

echo.
echo ========================================
echo   安装 Python 依赖
echo ========================================
echo.

REM 检查 Python
where python >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] Python 未安装
    echo 请访问 https://www.python.org/ 下载并安装 Python 3.9+
    echo 安装时请勾选 "Add Python to PATH"
    pause
    exit /b 1
)

echo [成功] Python 已安装
python --version

REM 检查 requirements.txt
if not exist "requirements.txt" (
    echo [警告] 未找到 requirements.txt
    echo 请确保在项目根目录运行此脚本
    goto skip_python_deps
)

echo [信息] 正在安装 Python 依赖包...
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

if %errorLevel% equ 0 (
    echo [成功] Python 依赖安装完成
) else (
    echo [警告] Python 依赖安装出现问题
)

:skip_python_deps

echo.
echo ========================================
echo   检查 Android Platform Tools
echo ========================================
echo.

REM 检查 ADB
where adb >nul 2>&1
if %errorLevel% equ 0 (
    echo [成功] ADB 已安装
    adb version
) else (
    echo [警告] ADB 未安装
    echo.
    echo Android Platform Tools 需要手动下载和配置:
    echo.
    echo 1. 下载 Platform Tools:
    echo    https://developer.android.com/tools/releases/platform-tools
    echo.
    echo 2. 解压到合适的位置 ^(例如: C:\Android\platform-tools^)
    echo.
    echo 3. 添加到系统环境变量 PATH:
    echo    - 右键 "此电脑" - "属性"
    echo    - "高级系统设置" - "环境变量"
    echo    - 在 "系统变量" 中找到 "Path"，点击 "编辑"
    echo    - 点击 "新建"，添加: C:\Android\platform-tools
    echo    - 点击 "确定" 保存
    echo.
    echo 4. 重启命令提示符或 PowerShell
    echo.
)

echo.
echo ========================================
echo   环境变量配置
echo ========================================
echo.

REM 检查 ANDROID_HOME
if defined ANDROID_HOME (
    echo [成功] ANDROID_HOME 已设置: %ANDROID_HOME%
) else if defined ANDROID_SDK_ROOT (
    echo [成功] ANDROID_SDK_ROOT 已设置: %ANDROID_SDK_ROOT%
) else (
    echo [警告] 未设置 ANDROID_HOME 环境变量
    echo.
    echo 建议设置环境变量 ^(可选但推荐^):
    echo   setx ANDROID_HOME "C:\Android"
    echo   setx ANDROID_SDK_ROOT "C:\Android"
    echo.
    echo 注意: 设置后需要重新打开命令提示符才能生效
    echo.
)

echo.
echo ========================================
echo   运行环境检测
echo ========================================
echo.

if exist "scripts\check_appium_env.py" (
    echo [信息] 运行环境检测脚本...
    python scripts\check_appium_env.py
) else (
    echo [警告] 未找到环境检测脚本
)

echo.
echo ========================================
echo   安装完成
echo ========================================
echo.
echo [成功] Appium 环境安装完成！
echo.
echo 下一步操作:
echo   1. 如果安装了 ADB，请连接 Android 设备并运行: adb devices
echo   2. 启动 Appium Server: appium --address 127.0.0.1 --port 4723
echo   3. 编辑配置文件: damai_appium\config.jsonc
echo   4. 启动图形界面: python start_gui.pyw
echo.
pause
