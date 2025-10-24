#!/bin/bash
# Appium 环境自动安装脚本 (Linux/macOS)
# 用法: ./install_appium.sh

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/debian_version ]; then
            DISTRO="debian"
        elif [ -f /etc/redhat-release ]; then
            DISTRO="redhat"
        elif [ -f /etc/arch-release ]; then
            DISTRO="arch"
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    else
        OS="unknown"
        DISTRO="unknown"
    fi
    
    print_info "检测到操作系统: $OS ($DISTRO)"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安装 Node.js 和 npm
install_nodejs() {
    print_header "安装 Node.js 和 npm"
    
    if command_exists node && command_exists npm; then
        NODE_VERSION=$(node --version)
        NPM_VERSION=$(npm --version)
        print_success "Node.js 已安装: $NODE_VERSION"
        print_success "npm 已安装: $NPM_VERSION"
        return 0
    fi
    
    print_info "开始安装 Node.js 和 npm..."
    
    if [ "$OS" == "macos" ]; then
        if command_exists brew; then
            print_info "使用 Homebrew 安装 Node.js..."
            brew install node
        else
            print_error "未检测到 Homebrew，请访问 https://nodejs.org/ 手动下载安装"
            return 1
        fi
    elif [ "$OS" == "linux" ]; then
        if [ "$DISTRO" == "debian" ]; then
            print_info "使用 apt 安装 Node.js..."
            sudo apt-get update
            sudo apt-get install -y nodejs npm
        elif [ "$DISTRO" == "redhat" ]; then
            print_info "使用 dnf 安装 Node.js..."
            sudo dnf install -y nodejs npm
        elif [ "$DISTRO" == "arch" ]; then
            print_info "使用 pacman 安装 Node.js..."
            sudo pacman -S --noconfirm nodejs npm
        else
            print_warning "未识别的 Linux 发行版，请访问 https://nodejs.org/ 手动安装"
            return 1
        fi
    else
        print_error "不支持的操作系统"
        return 1
    fi
    
    if command_exists node && command_exists npm; then
        print_success "Node.js 和 npm 安装成功"
    else
        print_error "Node.js 安装失败"
        return 1
    fi
}

# 安装 Appium Server
install_appium_server() {
    print_header "安装 Appium Server"
    
    if ! command_exists npm; then
        print_error "npm 未安装，无法继续"
        return 1
    fi
    
    if command_exists appium; then
        APPIUM_VERSION=$(appium -v)
        print_success "Appium Server 已安装: $APPIUM_VERSION"
    else
        print_info "安装 Appium Server..."
        npm install -g appium
        
        if command_exists appium; then
            print_success "Appium Server 安装成功"
        else
            print_error "Appium Server 安装失败"
            return 1
        fi
    fi
    
    # 安装 Appium Doctor（推荐）
    if command_exists appium-doctor; then
        print_success "Appium Doctor 已安装"
    else
        print_info "安装 Appium Doctor..."
        npm install -g appium-doctor || print_warning "Appium Doctor 安装失败（可选工具）"
    fi
    
    # 安装 UIAutomator2 驱动
    print_info "安装 UIAutomator2 驱动..."
    appium driver install uiautomator2 || print_warning "UIAutomator2 驱动安装失败"
}

# 安装 Python 依赖
install_python_deps() {
    print_header "安装 Python 依赖"
    
    if ! command_exists python3 && ! command_exists python; then
        print_error "Python 未安装，请先安装 Python 3.9+"
        return 1
    fi
    
    PYTHON_CMD="python3"
    if ! command_exists python3; then
        PYTHON_CMD="python"
    fi
    
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
    print_success "Python 版本: $PYTHON_VERSION"
    
    # 检查是否在项目目录
    if [ ! -f "requirements.txt" ]; then
        print_warning "未找到 requirements.txt，跳过 Python 依赖安装"
        print_info "请确保在项目根目录运行此脚本"
        return 0
    fi
    
    print_info "安装 Python 依赖包..."
    $PYTHON_CMD -m pip install --upgrade pip
    $PYTHON_CMD -m pip install -r requirements.txt
    
    print_success "Python 依赖安装完成"
}

# 安装 Android Platform Tools
install_android_tools() {
    print_header "Android Platform Tools 安装提示"
    
    if command_exists adb; then
        ADB_VERSION=$(adb version 2>&1 | head -n 1)
        print_success "ADB 已安装: $ADB_VERSION"
        return 0
    fi
    
    print_warning "ADB 未安装"
    print_info "Android Platform Tools 需要手动下载和配置："
    print_info ""
    print_info "1. 下载 Platform Tools:"
    print_info "   https://developer.android.com/tools/releases/platform-tools"
    print_info ""
    print_info "2. 解压到合适的位置，例如:"
    print_info "   Linux: ~/Android/platform-tools"
    print_info "   macOS: ~/Library/Android/platform-tools"
    print_info ""
    print_info "3. 添加到 PATH（将以下内容添加到 ~/.bashrc 或 ~/.zshrc）:"
    print_info "   export PATH=\"\$PATH:\$HOME/Android/platform-tools\""
    print_info ""
    print_info "4. 重新加载配置:"
    print_info "   source ~/.bashrc  # 或 source ~/.zshrc"
    print_info ""
    
    # 提供交互式安装选项（macOS Homebrew）
    if [ "$OS" == "macos" ] && command_exists brew; then
        echo -e "\n${YELLOW}是否使用 Homebrew 安装 Android Platform Tools? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_info "使用 Homebrew 安装..."
            brew install --cask android-platform-tools
            if command_exists adb; then
                print_success "ADB 安装成功"
            fi
        fi
    fi
}

# 配置环境变量
configure_environment() {
    print_header "环境变量配置"
    
    # 检查 ANDROID_HOME
    if [ -n "$ANDROID_HOME" ] || [ -n "$ANDROID_SDK_ROOT" ]; then
        print_success "Android SDK 环境变量已设置"
    else
        print_warning "未设置 ANDROID_HOME 环境变量"
        print_info "建议设置环境变量（可选但推荐）："
        print_info "将以下内容添加到 ~/.bashrc 或 ~/.zshrc:"
        print_info "  export ANDROID_HOME=\$HOME/Android/Sdk"
        print_info "  export ANDROID_SDK_ROOT=\$HOME/Android/Sdk"
        print_info "  export PATH=\$PATH:\$ANDROID_HOME/platform-tools"
    fi
}

# 运行环境检测
run_environment_check() {
    print_header "运行环境检测"
    
    if [ -f "scripts/check_appium_env.py" ]; then
        print_info "运行环境检测脚本..."
        python3 scripts/check_appium_env.py || python scripts/check_appium_env.py
    else
        print_warning "未找到环境检测脚本"
    fi
}

# 主函数
main() {
    print_header "Appium 环境自动安装脚本"
    
    # 检测操作系统
    detect_os
    
    if [ "$OS" == "unknown" ]; then
        print_error "不支持的操作系统"
        exit 1
    fi
    
    # 确认继续
    echo -e "\n${YELLOW}此脚本将安装以下组件:${NC}"
    echo "  - Node.js 和 npm (如果未安装)"
    echo "  - Appium Server 和 Appium Doctor"
    echo "  - Python 依赖包 (从 requirements.txt)"
    echo "  - UIAutomator2 驱动"
    echo ""
    echo -e "${YELLOW}是否继续? (y/n)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "安装已取消"
        exit 0
    fi
    
    # 执行安装步骤
    install_nodejs || exit 1
    install_appium_server || exit 1
    install_python_deps
    install_android_tools
    configure_environment
    
    # 运行环境检测
    run_environment_check
    
    print_header "安装完成"
    print_success "Appium 环境安装完成！"
    print_info ""
    print_info "下一步操作:"
    print_info "  1. 如果安装了 ADB，请连接 Android 设备并运行: adb devices"
    print_info "  2. 启动 Appium Server: appium --address 127.0.0.1 --port 4723"
    print_info "  3. 编辑配置文件: damai_appium/config.jsonc"
    print_info "  4. 启动图形界面: python start_gui.pyw"
    print_info ""
}

# 运行主函数
main
