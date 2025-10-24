# 脚本工具说明

本目录包含用于配置和管理 Appium 环境的脚本工具。

## 脚本列表

### 1. 环境检测脚本

**`check_appium_env.py`** - Appium 环境检测工具

**功能：**
- 检测 Node.js 和 npm 安装状态
- 检测 Appium Server 和版本
- 检测 Python 包依赖（Appium-Python-Client、selenium、pydantic）
- 检测 ADB 工具和已连接设备
- 检测 Android SDK 环境变量
- 检测 Appium 驱动（UIAutomator2）
- 提供详细的安装建议

**使用方法：**

```bash
# Windows
python scripts/check_appium_env.py

# Linux/macOS
python3 scripts/check_appium_env.py
```

**输出示例：**
```
============================================================
                     检查 Node.js 环境
============================================================

✅ Node.js 已安装: v18.16.0
✅ npm 已安装: 9.5.1

============================================================
                     环境检测摘要
============================================================

检测结果：
  Node.js              : 通过
  Appium Server        : 通过
  Python 包            : 通过
  ADB                  : 通过
  Appium 驱动          : 通过

✅ 所有环境检测通过！
```

---

### 2. 自动安装脚本（Windows）

**`install_appium.bat`** - Windows 平台自动安装工具

**功能：**
- 检查并安装 Node.js（需手动安装）
- 自动安装 Appium Server
- 自动安装 Appium Doctor
- 自动安装 UIAutomator2 驱动
- 安装 Python 依赖包
- 提供 ADB 和环境变量配置指导
- 运行环境检测验证

**使用方法：**

```cmd
# 方法 1: 双击运行
# 在文件资源管理器中双击 install_appium.bat

# 方法 2: 命令行运行
scripts\install_appium.bat
```

**前置要求：**
- Windows 10/11
- 已安装 Node.js（如未安装会提示手动下载）
- 已安装 Python 3.9+

**安装内容：**
1. ✅ Appium Server (通过 npm)
2. ✅ Appium Doctor (通过 npm)
3. ✅ UIAutomator2 驱动
4. ✅ Python 依赖包 (从 requirements.txt)
5. ℹ️  ADB 工具（提供手动安装指导）

---

### 3. 自动安装脚本（Linux/macOS）

**`install_appium.sh`** - Linux/macOS 平台自动安装工具

**功能：**
- 检测操作系统和发行版
- 自动安装 Node.js 和 npm（通过包管理器）
- 自动安装 Appium Server 和 Appium Doctor
- 自动安装 UIAutomator2 驱动
- 安装 Python 依赖包
- 提供 ADB 安装指导（macOS 支持 Homebrew 一键安装）
- 环境变量配置建议
- 运行环境检测验证

**使用方法：**

```bash
# 1. 添加执行权限
chmod +x scripts/install_appium.sh

# 2. 运行脚本
./scripts/install_appium.sh
```

**支持的系统：**
- ✅ Ubuntu/Debian (使用 apt)
- ✅ Fedora/RHEL (使用 dnf)
- ✅ Arch Linux (使用 pacman)
- ✅ macOS (使用 Homebrew)

**安装内容：**
1. ✅ Node.js 和 npm
2. ✅ Appium Server
3. ✅ Appium Doctor
4. ✅ UIAutomator2 驱动
5. ✅ Python 依赖包
6. ℹ️  ADB 工具（macOS 可通过 Homebrew 安装）

---

### 4. 快速启动脚本（Windows PowerShell）

**`app_mode_quickstart.ps1`** - App 模式快速启动

**功能：**
- 封装 App 模式命令行参数
- 支持定时抢票功能
- 简化启动流程

**使用方法：**

```powershell
# 基本用法
pwsh ./scripts/app_mode_quickstart.ps1 -ConfigPath .\damai_appium\config.jsonc

# 定时抢票
pwsh ./scripts/app_mode_quickstart.ps1 `
  -ConfigPath .\damai_appium\config.jsonc `
  -Retries 6 `
  -StartAt "2025-10-01 20:00:00" `
  -WarmupSec 120
```

详见 [APP_MODE_README.md](../docs/guides/APP_MODE_README.md)

---

## 使用场景

### 场景 1：首次配置环境

**推荐流程：**

1. **运行环境检测**（了解当前状态）
   ```bash
   python scripts/check_appium_env.py
   ```

2. **运行自动安装脚本**
   ```bash
   # Windows
   scripts\install_appium.bat
   
   # Linux/macOS
   chmod +x scripts/install_appium.sh
   ./scripts/install_appium.sh
   ```

3. **再次验证环境**
   ```bash
   python scripts/check_appium_env.py
   ```

4. **配置项目**
   - 编辑 `damai_appium/config.jsonc`
   - 参考 `config/appium_config.example.json`

---

### 场景 2：排查环境问题

**推荐流程：**

1. **运行环境检测**
   ```bash
   python scripts/check_appium_env.py
   ```

2. **根据输出检查具体组件**
   ```bash
   # 检查 Node.js
   node --version
   npm --version
   
   # 检查 Appium
   appium -v
   appium driver list --installed
   
   # 检查 ADB
   adb version
   adb devices -l
   
   # 检查 Python 包
   pip list | grep -i appium
   ```

3. **使用 Appium Doctor 诊断**
   ```bash
   appium-doctor --android
   ```

4. **查看详细文档**
   - [APP_MODE_README.md](../docs/guides/APP_MODE_README.md) - 完整安装指南
   - [config/README.md](../config/README.md) - 配置文件说明

---

### 场景 3：更新或重新安装

如果需要更新 Appium 或重新安装环境：

```bash
# 1. 卸载旧版本（可选）
npm uninstall -g appium
npm uninstall -g appium-doctor

# 2. 重新运行安装脚本
# Windows
scripts\install_appium.bat

# Linux/macOS
./scripts/install_appium.sh

# 3. 验证安装
python scripts/check_appium_env.py
```

---

## 常见问题

### Q1: 环境检测脚本报错 "未找到 Node.js"

**A:** 
1. 访问 https://nodejs.org/ 下载安装 Node.js LTS 版本
2. 安装时勾选 "Add to PATH"
3. 重启终端后重新运行检测脚本

---

### Q2: 自动安装脚本失败

**A:** 
1. 确保网络连接正常
2. Windows 用户尝试以管理员身份运行
3. Linux/macOS 用户确保有 sudo 权限
4. 查看错误信息，手动安装失败的组件

---

### Q3: ADB 未检测到设备

**A:**
1. 检查 USB 线是否连接正常
2. 确保设备已开启开发者模式和 USB 调试
3. 在设备上授权 USB 调试
4. 运行 `adb devices -l` 查看设备列表
5. 如果显示 "unauthorized"，重新授权

---

### Q4: Python 包安装失败

**A:**
1. 更新 pip：`python -m pip install --upgrade pip`
2. 使用国内镜像：`pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt`
3. 检查 Python 版本是否为 3.9+

---

## 脚本维护

这些脚本会随着项目更新而改进。如果遇到问题或有改进建议，请：

1. 查看项目文档：[docs/guides/APP_MODE_README.md](../docs/guides/APP_MODE_README.md)
2. 提交 Issue：https://github.com/10000ge10000/damai-ticket-assistant/issues
3. 贡献代码：欢迎提交 Pull Request

---

## 相关文档

- 📘 [App 模式零基础上手指南](../docs/guides/APP_MODE_README.md)
- 📘 [Web 模式使用指南](../docs/guides/WEB_MODE_README.md)
- 📘 [配置文件说明](../config/README.md)
- 📘 [项目主页 README](../README.md)

---

**最后更新：** 2024-10-23
