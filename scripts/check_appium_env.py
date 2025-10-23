#!/usr/bin/env python3
"""
Appium 环境检测脚本
检测 Appium 及相关依赖是否已正确安装和配置
"""

from __future__ import annotations

import os
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple


class Color:
    """终端颜色输出"""
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'


def print_header(text: str) -> None:
    """打印标题"""
    print(f"\n{Color.BOLD}{Color.BLUE}{'=' * 60}{Color.RESET}")
    print(f"{Color.BOLD}{Color.BLUE}{text:^60}{Color.RESET}")
    print(f"{Color.BOLD}{Color.BLUE}{'=' * 60}{Color.RESET}\n")


def print_success(text: str) -> None:
    """打印成功信息"""
    print(f"{Color.GREEN}✅ {text}{Color.RESET}")


def print_warning(text: str) -> None:
    """打印警告信息"""
    print(f"{Color.YELLOW}⚠️  {text}{Color.RESET}")


def print_error(text: str) -> None:
    """打印错误信息"""
    print(f"{Color.RED}❌ {text}{Color.RESET}")


def print_info(text: str) -> None:
    """打印普通信息"""
    print(f"{Color.BLUE}ℹ️  {text}{Color.RESET}")


def check_command(
    command: str,
    args: List[str],
    friendly_name: str,
) -> Tuple[bool, Optional[str], Optional[str]]:
    """
    检查命令是否可用
    
    Args:
        command: 命令名称
        args: 命令参数
        friendly_name: 友好名称
        
    Returns:
        (是否成功, 版本信息, 错误信息)
    """
    executable = shutil.which(command)
    if not executable:
        return False, None, f"未找到 {friendly_name}（命令：{command}）"
    
    try:
        result = subprocess.run(
            [executable, *args],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        
        if result.returncode != 0:
            return False, None, f"{friendly_name} 执行失败（返回码：{result.returncode}）"
        
        output = (result.stdout or result.stderr or "").strip()
        return True, output, None
        
    except subprocess.TimeoutExpired:
        return False, None, f"{friendly_name} 执行超时"
    except Exception as exc:
        return False, None, f"{friendly_name} 检测失败：{exc}"


def extract_version(output: str) -> Optional[str]:
    """从输出中提取版本号"""
    # 匹配 v1.2.3 或 1.2.3 格式
    match = re.search(r'v?(\d+\.\d+\.\d+)', output)
    if match:
        return match.group(1)
    return None


def check_node() -> Tuple[bool, Dict[str, any]]:
    """检查 Node.js 环境"""
    print_header("检查 Node.js 环境")
    
    result = {"installed": False, "version": None, "npm_version": None}
    
    # 检查 Node.js
    success, output, error = check_command("node", ["--version"], "Node.js")
    if success and output:
        version = extract_version(output)
        result["installed"] = True
        result["version"] = version
        print_success(f"Node.js 已安装: {output}")
    else:
        print_error(f"Node.js 未安装: {error}")
        print_info("安装方法：")
        print_info("  - Windows/macOS: 访问 https://nodejs.org/ 下载 LTS 版本")
        print_info("  - Linux (Ubuntu/Debian): sudo apt-get install nodejs npm")
        print_info("  - Linux (Fedora): sudo dnf install nodejs npm")
        print_info("  - macOS (Homebrew): brew install node")
        return False, result
    
    # 检查 npm
    success, output, error = check_command("npm", ["--version"], "npm")
    if success and output:
        version = extract_version(output)
        result["npm_version"] = version
        print_success(f"npm 已安装: {output}")
    else:
        print_warning(f"npm 未找到: {error}")
    
    return True, result


def check_appium_server() -> Tuple[bool, Dict[str, any]]:
    """检查 Appium Server"""
    print_header("检查 Appium Server")
    
    result = {"installed": False, "version": None, "path": None}
    
    success, output, error = check_command("appium", ["-v"], "Appium Server")
    if success and output:
        version = extract_version(output)
        result["installed"] = True
        result["version"] = version
        result["path"] = shutil.which("appium")
        print_success(f"Appium Server 已安装: {output}")
        print_info(f"安装路径: {result['path']}")
    else:
        print_error(f"Appium Server 未安装: {error}")
        print_info("安装方法：")
        print_info("  npm install -g appium")
        print_info("  推荐同时安装 appium-doctor：")
        print_info("  npm install -g appium-doctor")
        return False, result
    
    # 检查 Appium Doctor（可选但推荐）
    success, output, _ = check_command("appium-doctor", ["--version"], "Appium Doctor")
    if success:
        print_success(f"Appium Doctor 已安装: {output.splitlines()[0] if output else '检测通过'}")
    else:
        print_warning("Appium Doctor 未安装（可选工具）")
        print_info("  安装命令: npm install -g appium-doctor")
    
    return True, result


def check_python_packages() -> Tuple[bool, Dict[str, any]]:
    """检查 Python 包"""
    print_header("检查 Python 包")
    
    result = {"python_version": sys.version.split()[0], "packages": {}}
    
    print_success(f"Python 版本: {result['python_version']}")
    
    # 检查必需的 Python 包
    required_packages = [
        ("appium-python-client", "Appium-Python-Client"),
        ("selenium", "selenium"),
        ("pydantic", "pydantic"),
    ]
    
    all_installed = True
    
    for package_import, package_name in required_packages:
        try:
            module_name = package_import.replace("-", "_")
            module = __import__(module_name)
            version = getattr(module, "__version__", "未知版本")
            result["packages"][package_name] = version
            print_success(f"{package_name} 已安装: {version}")
        except ImportError:
            result["packages"][package_name] = None
            print_error(f"{package_name} 未安装")
            all_installed = False
    
    if not all_installed:
        print_info("\n安装缺失的包：")
        print_info("  pip install -r requirements.txt")
        print_info("或单独安装：")
        print_info("  pip install Appium-Python-Client>=3.1.0")
        print_info("  pip install selenium>=4.18.0")
        print_info("  pip install pydantic>=2.6.0")
    
    return all_installed, result


def check_adb() -> Tuple[bool, Dict[str, any]]:
    """检查 ADB 和 Android SDK"""
    print_header("检查 ADB 和 Android SDK")
    
    result = {"installed": False, "version": None, "devices": []}
    
    # 检查 ADB
    success, output, error = check_command("adb", ["version"], "ADB")
    if success and output:
        result["installed"] = True
        # 提取版本号
        for line in output.splitlines():
            if "Version" in line or "version" in line:
                result["version"] = line.strip()
                break
        print_success(f"ADB 已安装: {result['version'] or output.splitlines()[0]}")
    else:
        print_error(f"ADB 未安装: {error}")
        print_info("安装方法：")
        print_info("  1. 下载 Android Platform Tools:")
        print_info("     https://developer.android.com/tools/releases/platform-tools")
        print_info("  2. 解压到合适的位置（如 C:\\Android\\platform-tools）")
        print_info("  3. 将路径添加到系统环境变量 PATH 中")
        print_info("  4. 重启终端或命令提示符")
        return False, result
    
    # 检查已连接的设备
    try:
        device_result = subprocess.run(
            ["adb", "devices", "-l"],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        
        if device_result.returncode == 0:
            lines = device_result.stdout.strip().splitlines()
            devices = []
            for line in lines[1:]:  # 跳过第一行标题
                if line.strip() and "device" in line.lower():
                    devices.append(line.strip())
            
            result["devices"] = devices
            
            if devices:
                print_success(f"检测到 {len(devices)} 个设备:")
                for device in devices:
                    print_info(f"  - {device}")
            else:
                print_warning("未检测到已连接的 Android 设备")
                print_info("请确保：")
                print_info("  1. 设备已通过 USB 连接到电脑")
                print_info("  2. 设备已开启开发者模式和 USB 调试")
                print_info("  3. 在设备上允许了 USB 调试授权")
                print_info("  4. 尝试运行: adb devices")
    except Exception as exc:
        print_warning(f"检测设备时出错: {exc}")
    
    # 检查环境变量
    android_home = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    if android_home:
        print_success(f"Android SDK 环境变量已设置: {android_home}")
    else:
        print_warning("未设置 ANDROID_HOME 或 ANDROID_SDK_ROOT 环境变量")
        print_info("建议设置环境变量（可选但推荐）：")
        if platform.system() == "Windows":
            print_info("  setx ANDROID_HOME \"C:\\Android\"")
            print_info("  setx ANDROID_SDK_ROOT \"C:\\Android\"")
        else:
            print_info("  export ANDROID_HOME=/path/to/android/sdk")
            print_info("  export ANDROID_SDK_ROOT=/path/to/android/sdk")
    
    return True, result


def check_appium_drivers() -> Tuple[bool, Dict[str, any]]:
    """检查 Appium 驱动"""
    print_header("检查 Appium 驱动")
    
    result = {"drivers": {}}
    
    try:
        driver_result = subprocess.run(
            ["appium", "driver", "list", "--installed"],
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        
        if driver_result.returncode == 0:
            output = driver_result.stdout
            
            # 检查 UIAutomator2 驱动（Android）
            if "uiautomator2" in output.lower():
                print_success("UIAutomator2 驱动已安装（Android）")
                result["drivers"]["uiautomator2"] = True
            else:
                print_warning("UIAutomator2 驱动未安装（Android 必需）")
                print_info("安装命令: appium driver install uiautomator2")
                result["drivers"]["uiautomator2"] = False
            
            # 检查 XCUITest 驱动（iOS，可选）
            if "xcuitest" in output.lower():
                print_success("XCUITest 驱动已安装（iOS）")
                result["drivers"]["xcuitest"] = True
            else:
                print_info("XCUITest 驱动未安装（仅 iOS 需要）")
                result["drivers"]["xcuitest"] = False
        else:
            print_warning("无法列出 Appium 驱动")
            print_info("如果是 Appium 1.x，驱动是内置的，可以忽略此警告")
            
    except Exception as exc:
        print_warning(f"检查 Appium 驱动时出错: {exc}")
    
    return True, result


def generate_summary(checks: Dict[str, Tuple[bool, Dict]]) -> None:
    """生成检测结果摘要"""
    print_header("环境检测摘要")
    
    all_passed = all(check[0] for check in checks.values())
    
    print("\n检测结果：")
    for name, (passed, _) in checks.items():
        status = f"{Color.GREEN}通过{Color.RESET}" if passed else f"{Color.RED}失败{Color.RESET}"
        print(f"  {name:20s} : {status}")
    
    print("\n" + "=" * 60)
    if all_passed:
        print_success("所有环境检测通过！您可以开始使用 Appium 进行自动化测试。")
    else:
        print_error("部分环境检测未通过，请按照上述提示进行安装和配置。")
    
    print("\n下一步操作：")
    if not checks["Node.js"][0]:
        print_info("1. 安装 Node.js 和 npm")
    if not checks["Appium Server"][0]:
        print_info("2. 安装 Appium Server: npm install -g appium")
    if not checks["Python 包"][0]:
        print_info("3. 安装 Python 依赖: pip install -r requirements.txt")
    if not checks["ADB"][0]:
        print_info("4. 安装 Android Platform Tools 并配置 PATH")
    if checks.get("Appium 驱动") and not checks["Appium 驱动"][1].get("drivers", {}).get("uiautomator2"):
        print_info("5. 安装 UIAutomator2 驱动: appium driver install uiautomator2")
    
    if all_passed:
        print_info("\n配置文件模板位置：")
        print_info("  - damai_appium/config.example.json")
        print_info("  - config/appium_config.example.json（如果存在）")
        print_info("\n启动 Appium Server：")
        print_info("  appium --address 127.0.0.1 --port 4723")
        print_info("\n启动图形界面：")
        print_info("  python start_gui.pyw")
    
    print("=" * 60 + "\n")


def main() -> int:
    """主函数"""
    print(f"\n{Color.BOLD}Appium 环境检测工具{Color.RESET}")
    print(f"系统: {platform.system()} {platform.release()}")
    print(f"Python: {sys.version.split()[0]}")
    
    checks = {}
    
    # 执行各项检测
    checks["Node.js"] = check_node()
    checks["Appium Server"] = check_appium_server()
    checks["Python 包"] = check_python_packages()
    checks["ADB"] = check_adb()
    
    # 只有在 Appium Server 安装后才检查驱动
    if checks["Appium Server"][0]:
        checks["Appium 驱动"] = check_appium_drivers()
    
    # 生成摘要
    generate_summary(checks)
    
    # 返回状态码
    return 0 if all(check[0] for check in checks.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
