# Appium 环境配置完整指南

本文档提供 Appium 环境配置的完整说明，包括自动化工具、手动配置步骤和故障排查方法。

---

## 📋 目录

1. [快速开始](#快速开始)
2. [环境检测工具](#环境检测工具)
3. [自动安装脚本](#自动安装脚本)
4. [手动配置步骤](#手动配置步骤)
5. [配置文件说明](#配置文件说明)
6. [常见问题](#常见问题)
7. [相关资源](#相关资源)

---

## 快速开始

### 3 步完成环境配置

```bash
# 1. 检测当前环境状态
python scripts/check_appium_env.py

# 2. 运行自动安装脚本
# Windows:
scripts\install_appium.bat

# Linux/macOS:
./scripts/install_appium.sh

# 3. 再次验证环境
python scripts/check_appium_env.py
```

---

## 环境检测工具

### `scripts/check_appium_env.py`

**功能：**
全面检测 Appium 运行环境，包括所有依赖项和配置状态。

**检测项目：**

| 检测项 | 说明 | 必需性 |
|--------|------|--------|
| Node.js | JavaScript 运行时，Appium 依赖 | ✅ 必需 |
| npm | Node.js 包管理器 | ✅ 必需 |
| Appium Server | 自动化服务器 | ✅ 必需 |
| Appium Doctor | 诊断工具 | ⚠️ 推荐 |
| Python 包 | appium-python-client, selenium, pydantic | ✅ 必需 |
| ADB | Android 调试桥 | ✅ 必需（Android） |
| Android SDK | 环境变量配置 | ⚠️ 推荐 |
| UIAutomator2 | Appium 驱动（Android） | ✅ 必需（Android） |

**使用方法：**

```bash
# Windows
python scripts/check_appium_env.py

# Linux/macOS
python3 scripts/check_appium_env.py
```

**输出解读：**

- ✅ 绿色：检测通过
- ⚠️ 黄色：警告（可选项缺失或配置建议）
- ❌ 红色：错误（必需项缺失）

---

## 自动安装脚本

### Windows: `scripts/install_appium.bat`

**安装内容：**
1. ✅ Appium Server (通过 npm)
2. ✅ Appium Doctor (通过 npm)
3. ✅ UIAutomator2 驱动
4. ✅ Python 依赖包
5. ℹ️ ADB 安装指导（需手动）

**使用方法：**

```cmd
# 方法 1: 双击 install_appium.bat 文件
# 方法 2: 命令行运行
scripts\install_appium.bat
```

**前置条件：**
- ✅ 已安装 Node.js（如未安装会提示下载）
- ✅ 已安装 Python 3.9+

### Linux/macOS: `scripts/install_appium.sh`

**安装内容：**
1. ✅ Node.js 和 npm（通过系统包管理器）
2. ✅ Appium Server
3. ✅ Appium Doctor
4. ✅ UIAutomator2 驱动
5. ✅ Python 依赖包
6. ℹ️ ADB 安装指导（macOS 支持 Homebrew）

**使用方法：**

```bash
# 添加执行权限
chmod +x scripts/install_appium.sh

# 运行脚本
./scripts/install_appium.sh
```

**支持的系统：**
- Ubuntu/Debian (apt)
- Fedora/RHEL (dnf)
- Arch Linux (pacman)
- macOS (Homebrew)

---

## 手动配置步骤

如果自动安装脚本失败或需要自定义配置，请按以下步骤手动安装。

### 1. 安装 Node.js 和 npm

**Windows:**
1. 访问 https://nodejs.org/
2. 下载 LTS 版本安装包
3. 安装时勾选 "Add to PATH"
4. 验证：`node --version && npm --version`

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y nodejs npm
```

**macOS:**
```bash
brew install node
```

### 2. 安装 Appium Server

```bash
# 全局安装 Appium
npm install -g appium

# 安装 Appium Doctor（推荐）
npm install -g appium-doctor

# 验证安装
appium -v
```

### 3. 安装 Appium 驱动

```bash
# Android 驱动（必需）
appium driver install uiautomator2

# iOS 驱动（可选）
appium driver install xcuitest

# 查看已安装驱动
appium driver list --installed
```

### 4. 安装 Python 依赖

```bash
# 升级 pip
python -m pip install --upgrade pip

# 安装项目依赖
pip install -r requirements.txt
```

### 5. 安装 Android Platform Tools

**Windows:**
1. 下载：https://developer.android.com/tools/releases/platform-tools
2. 解压到 `C:\Android\platform-tools`
3. 添加到系统环境变量 PATH
4. 重启命令提示符
5. 验证：`adb version`

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install -y android-tools-adb

# 或下载官方版本
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip -d ~/Android
echo 'export PATH="$PATH:$HOME/Android/platform-tools"' >> ~/.bashrc
source ~/.bashrc
```

**macOS:**
```bash
# 使用 Homebrew
brew install --cask android-platform-tools

# 验证
adb version
```

### 6. 配置环境变量（推荐）

**Windows:**
```cmd
setx ANDROID_HOME "C:\Android"
setx ANDROID_SDK_ROOT "C:\Android"
```

**Linux/macOS:**
```bash
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export ANDROID_SDK_ROOT=$HOME/Android/Sdk' >> ~/.bashrc
source ~/.bashrc
```

---

## 配置文件说明

### 配置文件位置

- **项目配置**：`damai_appium/config.jsonc`
- **配置模板**：`config/appium_config.example.json`

### 最小配置示例

```json
{
  "server_url": "http://127.0.0.1:4723/wd/hub",
  "keyword": "演出名称",
  "users": ["观演人姓名"],
  "city": "北京",
  "price_index": 0,
  "if_commit_order": false,
  "device_caps": {
    "udid": "设备序列号",
    "deviceName": "我的手机",
    "platformVersion": "13"
  }
}
```

### 获取设备信息

```bash
# 列出已连接设备
adb devices -l

# 输出示例：
# 1234567890ABCDEF    device usb:1-1 product:xxx model:xxx
#                      ^
#                      这就是 UDID
```

详细配置说明请查看 [配置文件文档](../config/README.md)。

---

## 常见问题

### Q1: "未检测到 Appium 运行环境"

**原因：** Python 包未安装或版本不兼容

**解决：**
```bash
# 检查环境
python scripts/check_appium_env.py

# 重新安装依赖
pip install -r requirements.txt

# 或单独安装
pip install --upgrade Appium-Python-Client>=3.1.0
```

---

### Q2: "未找到 Node.js"

**原因：** Node.js 未安装或未添加到 PATH

**解决：**
1. 访问 https://nodejs.org/ 下载安装 Node.js LTS 版本
2. Windows 用户确保安装时勾选 "Add to PATH"
3. 重启终端验证：`node --version`

---

### Q3: "未找到 Appium CLI"

**原因：** Appium Server 未安装

**解决：**
```bash
# 安装 Appium
npm install -g appium

# 验证
appium -v

# 如果提示权限错误（Linux/macOS）
sudo npm install -g appium
```

---

### Q4: "未找到 adb"

**原因：** Android Platform Tools 未安装或未配置 PATH

**解决：**

**Windows:**
1. 下载 Platform Tools
2. 解压到固定位置（如 `C:\Android\platform-tools`）
3. 添加到系统环境变量 PATH
4. 重启命令提示符

**Linux/macOS:**
```bash
# Ubuntu/Debian
sudo apt-get install android-tools-adb

# macOS
brew install --cask android-platform-tools
```

---

### Q5: "adb devices 没有设备"

**原因：** 设备未连接或未授权

**解决：**
1. 检查 USB 线连接（建议使用原装线）
2. 手机端开启开发者模式和 USB 调试
3. 在手机上授权 USB 调试（选择"始终允许"）
4. 尝试重新连接：
   ```bash
   adb kill-server
   adb start-server
   adb devices -l
   ```

---

### Q6: "UIAutomator2 驱动未安装"

**原因：** Appium 2.x 需要单独安装驱动

**解决：**
```bash
# 安装 UIAutomator2 驱动
appium driver install uiautomator2

# 验证
appium driver list --installed
```

---

### Q7: "Appium-Python-Client 导入错误"

**原因：** Python 包版本不兼容

**解决：**
```bash
# 卸载旧版本
pip uninstall Appium-Python-Client

# 安装指定版本
pip install Appium-Python-Client>=3.1.0

# 验证
python -c "import appium; print(appium.__version__)"
```

---

### Q8: 运行 appium-doctor 发现警告

**说明：** appium-doctor 会列出所有可选和必需的依赖

**解读：**
```bash
appium-doctor --android

# 输出中：
# ✔ 表示必需项已满足
# ✖ 表示必需项缺失（需要修复）
# ⚠ 表示可选项缺失（可以忽略）
```

常见警告项：
- `ANDROID_HOME` / `ANDROID_SDK_ROOT` 未设置 → 建议设置但非必需
- `JAVA_HOME` 未设置 → 仅开发 Appium 插件需要
- iOS 相关工具缺失 → 仅在 macOS 开发 iOS 应用需要

---

## 验证清单

配置完成后，请逐项验证：

```bash
# 1. Node.js 和 npm
node --version   # 应输出版本号，如 v18.16.0
npm --version    # 应输出版本号，如 9.5.1

# 2. Appium Server
appium -v        # 应输出版本号，如 2.0.0

# 3. Appium 驱动
appium driver list --installed
# 应列出 uiautomator2

# 4. ADB
adb version      # 应输出 ADB 版本信息
adb devices -l   # 应列出已连接设备（如果有）

# 5. Python 包
pip list | grep -i appium    # 应显示 Appium-Python-Client
pip list | grep -i selenium  # 应显示 selenium

# 6. 完整环境检测
python scripts/check_appium_env.py
# 所有项目应显示 ✅
```

---

## 相关资源

### 官方文档
- [Appium 官方文档](https://appium.io/docs/en/latest/)
- [Node.js 官网](https://nodejs.org/)
- [Android Platform Tools](https://developer.android.com/tools/releases/platform-tools)

### 项目文档
- [App 模式零基础上手指南](guides/APP_MODE_README.md)
- [配置文件说明](../config/README.md)
- [脚本工具文档](../scripts/README.md)

### 视频教程
推荐搜索：
- "Appium 环境搭建教程"
- "Android 开发者模式设置"
- "adb 使用教程"

---

## 获取帮助

如果按照本文档操作仍遇到问题：

1. **运行环境检测**：`python scripts/check_appium_env.py`
2. **查看详细日志**：Appium Server 终端输出
3. **搜索错误信息**：将错误信息复制到搜索引擎
4. **提交 Issue**：https://github.com/10000ge10000/damai-ticket-assistant/issues
   - 附上环境检测结果
   - 附上错误截图或日志
   - 说明操作系统和版本

---

**最后更新：** 2024-10-23

**文档版本：** 1.0.0
