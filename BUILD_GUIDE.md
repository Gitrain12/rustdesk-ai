
# RustDesk AI - 构建指南

## 快速开始

### 方式 1：使用批处理脚本（推荐）

双击运行：
```
d:\Linking\rustdesk-app-package\build_apk.bat
```

### 方式 2：使用命令行

```powershell
cd d:\Linking\rustdesk-app-package\flutter

# 获取依赖
D:\flutter-SDK\flutter\bin\flutter.bat pub get

# 构建 Debug APK
D:\flutter-SDK\flutter\bin\flutter.bat build apk --debug

# 构建 Release APK
D:\flutter-SDK\flutter\bin\flutter.bat build apk --release
```

## APK 输出位置

构建完成后，APK 文件位于：

```
d:\Linking\rustdesk-app-package\flutter\build\android\app\
├── debug\
│   └── app-debug.apk          # Debug 版本
└── release\
    └── app-release.apk        # Release 版本
```

## 安装到设备

### 使用 ADB 安装

```powershell
# 连接设备后
adb install d:\Linking\rustdesk-app-package\flutter\build\android\app\release\app-release.apk
```

### 通过 USB 传输到手机后手动安装

## 当前项目状态

### ✅ 已完成

- AI 后端服务（运行中）
- Flutter 移动应用完整代码
- DeepSeek + 千问 API 配置
- 所有 UI 界面和功能模块

### 📋 待完成

- 构建 APK（需要依赖下载和编译）
- 服务器部署到云端
- 真机测试

## 配置 AI 后端服务

当前 AI 后端服务已经运行在 `http://localhost:8080`

配置文件：
```
d:\Linking\rustdesk-app-package\ai-backend\.env
```

API Key 已配置：
- DeepSeek: `sk-5c8f3b46ed9b4cc29f203ec504c11b3b`
- 千问: `sk-fc58033f41134ed4bd5e126690ff9804`

## 常见问题

### Flutter 找不到依赖

请确认以下环境变量：

```powershell
# 添加 Flutter 路径
set PATH=%PATH%;D:\flutter-SDK\flutter\bin
```

### Gradle 构建失败

```powershell
cd d:\Linking\rustdesk-app-package\flutter\android
.\gradlew.bat clean
```

### ADB 找不到设备

```powershell
adb devices
# 如果找不到设备，请启用 USB 调试
```

## 下一步

1. 成功构建 APK 后
2. 安装到 Android 设备测试
3. 配置 RustDesk 服务器
4. 测试远程连接
5. 测试 AI 功能

