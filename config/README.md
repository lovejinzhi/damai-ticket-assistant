# Appium 配置文件说明

本目录包含 Appium 和大麦票务助手的配置文件模板。

## 配置文件

### `appium_config.example.json`

完整的 Appium 配置模板，包含：

- **Appium 服务器配置**：服务器地址和连接设置
- **大麦票务配置**：演出信息、观演人、城市、日期、价格等
- **设备配置（Device Capabilities）**：Android/iOS 设备的详细配置
- **高级配置**：超时时间、重试设置等
- **多设备配置示例**：批量部署参考

## 使用方法

### 1. 复制模板文件

```bash
# 复制到项目使用的配置位置
cp config/appium_config.example.json damai_appium/config.jsonc
```

或者直接编辑现有的 `damai_appium/config.jsonc`。

### 2. 填写必需字段

最少需要配置以下字段：

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

### 3. 获取设备信息

运行以下命令获取设备的 UDID：

```bash
# 列出已连接的设备
adb devices -l
```

输出示例：
```
List of devices attached
1234567890ABCDEF       device usb:1-1 product:xxx model:xxx device:xxx
```

其中 `1234567890ABCDEF` 就是 UDID。

### 4. 测试配置

在正式抢票前，建议先测试配置：

```bash
# 设置 if_commit_order 为 false
# 然后运行
python -m damai_appium.damai_app_v2 --config damai_appium/config.jsonc
```

观察日志输出，确保能够：
- ✅ 连接到 Appium Server
- ✅ 连接到设备
- ✅ 打开大麦 App
- ✅ 搜索到目标演出
- ✅ 选择价格和观演人

## 配置字段说明

### Appium Server 配置

| 字段 | 必需 | 说明 | 示例 |
|------|------|------|------|
| `server_url` | ✅ | Appium Server 地址 | `http://127.0.0.1:4723/wd/hub` |

### 票务配置

| 字段 | 必需 | 说明 | 示例 |
|------|------|------|------|
| `keyword` | ✅ | 演出搜索关键词 | `"张学友演唱会"` |
| `users` | ✅ | 观演人姓名列表 | `["张三", "李四"]` |
| `city` | ✅ | 城市名称 | `"北京"` |
| `date` | ❌ | 演出日期 | `"2025-10-18"` |
| `price` | ❌ | 价格描述 | `"VIP"` |
| `price_index` | ✅ | 价格索引（从0开始） | `0` |
| `if_commit_order` | ✅ | 是否提交订单 | `false` / `true` |

### 设备配置 (device_caps)

| 字段 | 必需 | 说明 | 示例 |
|------|------|------|------|
| `platformName` | ✅ | 平台 | `"Android"` / `"iOS"` |
| `platformVersion` | ✅ | 系统版本 | `"13"` |
| `deviceName` | ✅ | 设备名称 | `"我的手机"` |
| `udid` | ✅ | 设备标识符 | `"1234567890ABCDEF"` |
| `automationName` | ✅ | 自动化引擎 | `"UiAutomator2"` |
| `appPackage` | ✅ | 应用包名 | `"cn.damai"` |
| `appActivity` | ✅ | 启动Activity | `"cn.damai.launcher.activity.SplashActivity"` |
| `noReset` | ❌ | 保留应用数据 | `true` |
| `autoGrantPermissions` | ❌ | 自动授权 | `true` |

### 高级配置

| 字段 | 必需 | 说明 | 推荐值 |
|------|------|------|--------|
| `wait_timeout` | ❌ | 等待超时（秒） | 开售: `1.4-1.6`<br>守候: `1.8-2.2` |
| `retry_delay` | ❌ | 重试延迟（秒） | 开售: `1.0-1.2`<br>守候: `1.5` |
| `max_retries` | ❌ | 最大重试次数 | `3-10` |

## 配置示例场景

### 场景 1：开售冲刺（首发抢票）

```json
{
  "server_url": "http://127.0.0.1:4723/wd/hub",
  "keyword": "演唱会名称",
  "users": ["真实姓名"],
  "city": "北京",
  "price_index": 0,
  "if_commit_order": true,
  "wait_timeout": 1.5,
  "retry_delay": 1.0,
  "max_retries": 5,
  "device_caps": {
    "udid": "你的设备UDID",
    "deviceName": "主力手机",
    "platformVersion": "13"
  }
}
```

### 场景 2：守候回流（捡漏模式）

```json
{
  "server_url": "http://127.0.0.1:4723/wd/hub",
  "keyword": "演唱会名称",
  "users": ["真实姓名"],
  "city": "北京",
  "price_index": 0,
  "if_commit_order": true,
  "wait_timeout": 2.0,
  "retry_delay": 1.5,
  "max_retries": 10,
  "device_caps": {
    "udid": "你的设备UDID",
    "deviceName": "主力手机",
    "platformVersion": "13"
  }
}
```

### 场景 3：测试模式（不提交订单）

```json
{
  "server_url": "http://127.0.0.1:4723/wd/hub",
  "keyword": "测试演出",
  "users": [],
  "city": "北京",
  "price_index": 0,
  "if_commit_order": false,
  "device_caps": {
    "udid": "你的设备UDID",
    "deviceName": "测试设备",
    "platformVersion": "13"
  }
}
```

## 注意事项

1. **安全性**
   - ⚠️ 不要将包含真实个人信息的配置文件提交到公共仓库
   - 建议将 `config.jsonc` 添加到 `.gitignore`

2. **测试先行**
   - 首次使用务必设置 `if_commit_order: false` 进行测试
   - 确认流程正常后再设置为 `true`

3. **版本兼容**
   - 确保大麦 App 是最新版本
   - 定期更新 Appium Server 和 Python 包

4. **多设备配置**
   - 多设备功能仍在完善中
   - 当前版本支持单设备配置

## 相关文档

- [App 模式零基础上手指南](../docs/guides/APP_MODE_README.md)
- [环境检测脚本使用](../scripts/check_appium_env.py)
- [自动安装脚本](../scripts/install_appium.sh)

## 获取帮助

如遇问题，请：

1. 运行环境检测：`python scripts/check_appium_env.py`
2. 查看文档：[APP_MODE_README.md](../docs/guides/APP_MODE_README.md)
3. 提交 Issue：https://github.com/10000ge10000/damai-ticket-assistant/issues
