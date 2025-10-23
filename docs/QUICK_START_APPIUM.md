# Appium 环境配置快速参考卡

> 💡 **提示**：将此文档保存或打印，作为快速参考指南

---

## 🚀 3 步快速配置

```bash
# 第 1 步：检查环境
python scripts/check_appium_env.py

# 第 2 步：自动安装（选择一个）
scripts\install_appium.bat      # Windows
./scripts/install_appium.sh     # Linux/macOS

# 第 3 步：再次验证
python scripts/check_appium_env.py
```

---

## 📋 必需组件清单

| 组件 | 安装命令 | 验证命令 |
|------|----------|----------|
| Node.js | 访问 https://nodejs.org/ | `node --version` |
| npm | Node.js 自带 | `npm --version` |
| Appium Server | `npm install -g appium` | `appium -v` |
| Appium Doctor | `npm install -g appium-doctor` | `appium-doctor --version` |
| UIAutomator2 驱动 | `appium driver install uiautomator2` | `appium driver list --installed` |
| Python 包 | `pip install -r requirements.txt` | `pip list \| grep -i appium` |
| ADB | 见下方"ADB 安装" | `adb version` |

---

## 📱 ADB 安装

### Windows
1. 下载：https://developer.android.com/tools/releases/platform-tools
2. 解压到 `C:\Android\platform-tools`
3. 添加到系统 PATH：
   - 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   - 编辑 Path，添加：`C:\Android\platform-tools`
4. 重启命令提示符
5. 验证：`adb version`

### Linux (Ubuntu/Debian)
```bash
sudo apt-get install android-tools-adb
adb version
```

### macOS
```bash
brew install --cask android-platform-tools
adb version
```

---

## 🔧 常用命令速查

### 环境检测
```bash
# 完整检测
python scripts/check_appium_env.py

# 单项检测
node --version                      # Node.js
npm --version                       # npm
appium -v                           # Appium
appium driver list --installed      # Appium 驱动
adb version                         # ADB
adb devices -l                      # 已连接设备
pip list | grep -i appium          # Python 包
```

### 诊断工具
```bash
# Appium Doctor（全面检查）
appium-doctor --android

# 检查 Android SDK 环境变量
echo $ANDROID_HOME              # Linux/macOS
echo %ANDROID_HOME%             # Windows
```

### 启动服务
```bash
# 启动 Appium Server（默认 4723 端口）
appium

# 指定端口和地址
appium --address 127.0.0.1 --port 4723

# 后台运行（Linux/macOS）
appium > appium.log 2>&1 &

# 停止 Appium Server
# Windows: Ctrl+C 或关闭窗口
# Linux/macOS: Ctrl+C 或 killall appium
```

### 设备管理
```bash
# 列出设备
adb devices -l

# 重启 ADB
adb kill-server
adb start-server

# 检查设备连接
adb devices -l
# 应显示: <设备ID>    device

# 查看设备信息
adb shell getprop ro.build.version.release  # Android 版本
adb shell getprop ro.product.model           # 设备型号
```

---

## ⚙️ 配置文件位置

| 文件 | 用途 |
|------|------|
| `damai_appium/config.jsonc` | 主配置文件（使用此文件） |
| `config/appium_config.example.json` | 完整配置模板 |
| `damai_appium/config.example.json` | 简化配置模板 |

### 最小配置
```json
{
  "server_url": "http://127.0.0.1:4723/wd/hub",
  "keyword": "演出名称",
  "users": ["观演人"],
  "city": "北京",
  "price_index": 0,
  "if_commit_order": false,
  "device_caps": {
    "udid": "设备序列号",
    "deviceName": "手机",
    "platformVersion": "13"
  }
}
```

### 获取设备 UDID
```bash
adb devices -l
# 输出中第一列就是 UDID
# 例如: 1234567890ABCDEF    device
```

---

## ❌ 快速故障排查

### 问题 1: "未检测到 Appium 运行环境"
```bash
# 解决方案
python scripts/check_appium_env.py
pip install -r requirements.txt
```

### 问题 2: "未找到 Node.js"
```bash
# 解决方案
# 访问 https://nodejs.org/ 下载安装
# 安装时勾选 "Add to PATH"
# 重启终端验证
node --version
```

### 问题 3: "未找到 Appium CLI"
```bash
# 解决方案
npm install -g appium
appium -v
```

### 问题 4: "未找到 adb"
```bash
# 解决方案（见上方"ADB 安装"）
# 安装后验证
adb version
```

### 问题 5: "adb devices 没有设备"
```bash
# 解决方案
# 1. 检查 USB 线连接
# 2. 手机开启 USB 调试
# 3. 授权 USB 调试（选择"始终允许"）
# 4. 重启 ADB
adb kill-server
adb start-server
adb devices -l
```

### 问题 6: "UIAutomator2 驱动未安装"
```bash
# 解决方案
appium driver install uiautomator2
appium driver list --installed
```

---

## 🏃 运行流程

### 1. 启动 Appium Server
```bash
# 打开新终端，运行
appium --address 127.0.0.1 --port 4723
# 保持此窗口打开
```

### 2. 连接设备
```bash
# 打开另一个终端，检查设备
adb devices -l
# 应显示: <UDID>    device
```

### 3. 配置项目
```bash
# 编辑配置文件
# Windows: notepad damai_appium\config.jsonc
# Linux/macOS: nano damai_appium/config.jsonc

# 填写必需字段：
# - server_url
# - keyword
# - users
# - city
# - device_caps.udid
```

### 4. 启动图形界面
```bash
python start_gui.pyw
# 或
python damai_gui.py
```

### 5. 开始抢票
```
1. 切换到"App 模式"标签
2. 点击"环境检测"
3. 点击"刷新设备"
4. 加载配置文件
5. 点击"开始抢票"
```

---

## 📚 文档链接

- **完整指南**：[docs/guides/APP_MODE_README.md](guides/APP_MODE_README.md)
- **环境配置**：[docs/APPIUM_ENV_SETUP.md](APPIUM_ENV_SETUP.md)
- **配置说明**：[config/README.md](../config/README.md)
- **脚本工具**：[scripts/README.md](../scripts/README.md)

---

## 🆘 获取帮助

### 自助排查
```bash
# 1. 运行环境检测
python scripts/check_appium_env.py

# 2. 查看 Appium Doctor
appium-doctor --android

# 3. 查看日志
# GUI 右侧日志面板
# 或使用 --export-report 导出 JSON
```

### 提交问题
访问：https://github.com/10000ge10000/damai-ticket-assistant/issues

请附上：
- 环境检测结果
- 错误截图或日志
- 操作系统和版本

---

## ⚡ 快捷键和技巧

### 命令行技巧
```bash
# 查看 Appium 版本
appium -v

# 查看帮助
appium --help

# 检查端口占用（Windows）
netstat -ano | findstr :4723

# 检查端口占用（Linux/macOS）
lsof -i :4723

# 杀死进程（Windows）
taskkill /PID <PID> /F

# 杀死进程（Linux/macOS）
kill -9 <PID>
```

### ADB 快捷命令
```bash
# 快速重启 ADB
adb kill-server && adb start-server

# 查看所有设备
adb devices -l

# 安装 APK
adb install app.apk

# 卸载应用
adb uninstall <包名>

# 查看日志
adb logcat
```

---

## ✅ 验证清单

在开始抢票前，确认以下所有项目：

- [ ] Node.js 已安装（`node --version`）
- [ ] Appium Server 已安装（`appium -v`）
- [ ] UIAutomator2 驱动已安装
- [ ] Python 包已安装（`pip list | grep -i appium`）
- [ ] ADB 已安装（`adb version`）
- [ ] 设备已连接（`adb devices -l` 显示 device）
- [ ] Appium Server 正在运行
- [ ] 配置文件已填写完整
- [ ] 设备已开启 USB 调试
- [ ] 大麦 App 已安装在设备上
- [ ] 设备已登录大麦账号

---

**版本**：1.0.0  
**更新日期**：2024-10-23

---

> 💡 **建议**：将本文档添加到浏览器收藏夹，以便随时查阅！
