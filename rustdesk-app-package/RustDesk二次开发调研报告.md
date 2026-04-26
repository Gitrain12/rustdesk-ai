# RustDesk技术架构与二次开发方案

## 一、RustDesk技术架构分析

### 1.1 项目概述

RustDesk是一个开源的远程桌面解决方案，核心使用Rust语言编写，UI层使用Flutter框架。官方定位为TeamViewer的开源替代方案，支持Windows、macOS、Linux、iOS、Android和Web平台。

**核心仓库：**
- 主客户端：`https://github.com/rustdesk/rustdesk` (⭐ 76k+ stars)
- 开源服务器：`https://github.com/rustdesk/rustdesk-server`
- Pro服务器：`https://github.com/rustdesk/rustdesk-server-pro`

### 1.2 源码目录结构

```
rustdesk/
├── src/                          # Rust核心代码
│   ├── main.rs                   # 应用入口点
│   ├── core_main.rs              # 核心逻辑入口
│   ├── lib.rs                    # 核心库定义
│   ├── client.rs                 # 客户端连接逻辑
│   ├── server.rs                 # 服务端连接逻辑
│   ├── rendezvous_mediator.rs    # NAT穿透与连接协调
│   ├── flutter_ffi.rs           # Flutter-Rust FFI接口
│   ├── clipboard.rs              # 剪贴板同步
│   ├── port_forward.rs           # 端口转发
│   ├── auth_2fa.rs               # 双因素认证
│   ├── privacy_mode/             # 隐私模式模块
│   ├── plugin/                   # 插件系统
│   ├── server/                   # 服务端服务模块
│   │   ├── connection.rs        # 连接管理
│   │   ├── video_service.rs     # 视频服务
│   │   ├── audio_service.rs     # 音频服务
│   │   └── input_service.rs      # 输入服务
│   ├── platform/                 # 平台特定实现
│   │   ├── windows.rs
│   │   ├── linux.rs
│   │   └── macos.rs
│   ├── ui/                       # Sciter桌面UI (已弃用)
│   └── lang/                     # 国际化资源
│
├── flutter/                      # Flutter移动端/桌面端代码
│   ├── lib/
│   │   ├── main.dart             # Flutter入口
│   │   ├── common.dart           # 通用工具与常量
│   │   ├── models/               # 数据模型
│   │   │   ├── peer_model.dart   # 远程设备模型
│   │   │   ├── file_model.dart  # 文件传输模型
│   │   │   ├── chat_model.dart  # 聊天功能模型
│   │   │   └── desktop_render_texture.dart  # 渲染纹理
│   │   ├── mobile/               # 移动端专用
│   │   │   ├── pages/
│   │   │   │   ├── home_page.dart       # 主页
│   │   │   │   ├── connection_page.dart # 连接页
│   │   │   │   ├── server_page.dart    # 服务端页
│   │   │   │   ├── remote_page.dart    # 远程控制页
│   │   │   │   └── settings_page.dart  # 设置页
│   │   │   └── gestures.dart     # 手势识别
│   │   ├── desktop/              # 桌面端专用
│   │   │   └── pages/
│   │   ├── web/                  # Web端
│   │   └── widgets/              # 共享组件
│   ├── android/                  # Android原生代码
│   │   └── app/src/main/kotlin/
│   │       └── com/carriez/flutter_hbb/
│   │           └── MainActivity.kt
│   ├── ios/                      # iOS原生代码
│   │   └── Runner/
│   │       └── AppDelegate.swift
│   ├── pubspec.yaml              # Flutter依赖配置
│   ├── build_android.sh          # Android构建脚本
│   └── build_ios.sh              # iOS构建脚本
│
├── libs/                         # 共享Rust库
│   ├── hbb_common/               # 通用工具库
│   ├── scrap/                    # 跨平台屏幕捕获
│   ├── enigo/                    # 跨平台输入模拟
│   └── clipboard/                # 系统剪贴板访问
│
├── server/                       # 独立服务端代码 (如有)
└── res/                          # 资源文件
```

### 1.3 核心架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        用户界面层 (UI Layer)                      │
├─────────────────────────────────────────────────────────────────┤
│  Flutter UI (移动端/桌面端/网页)  │  Sciter UI (已弃用)          │
│  flutter/lib/mobile/           │  src/ui/                      │
│  flutter/lib/desktop/           │                               │
└─────────────────────────────────────────────────────────────────┘
                              │ FFI (flutter_rust_bridge)
┌─────────────────────────────────────────────────────────────────┐
│                      应用核心层 (Core Layer)                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Client     │  │   Server     │  │ Rendezvous Mediator  │  │
│  │  (连接发起)   │  │  (连接接收)   │  │  (NAT穿透/信令)       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Video Svc   │  │  Audio Svc   │  │   Clipboard Svc      │  │
│  │  (视频编码)   │  │  (音频传输)   │  │   (剪贴板同步)        │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    跨平台库层 (Platform Libraries)                 │
├─────────────────────────────────────────────────────────────────┤
│  libs/scrap/ (屏幕捕获)  │  libs/enigo/ (输入模拟)  │  libs/clipboard/ │
└─────────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────────┐
│                       系统层 (System Layer)                       │
├─────────────────────────────────────────────────────────────────┤
│  Windows/macOS/Linux API  │  Android/iOS Native  │  Codecs     │
└─────────────────────────────────────────────────────────────────┘
```

### 1.4 技术栈总结

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 移动端UI | Flutter 3.24+ | 跨平台UI框架，支持Material 3 |
| 桌面端UI | Flutter / Sciter | Flutter为新方向，Sciter已弃用 |
| 核心逻辑 | Rust | 内存安全，高性能 |
| FFI桥接 | flutter_rust_bridge | Dart与Rust类型安全绑定 |
| 视频编码 | libvpx/AV1, aom/AV1, H264/H265 | 软件/硬件编码支持 |
| 音频编码 | opus | 高效音频压缩 |
| 加密 | libsodium (NaCl) | ChaCha20-Poly1305, Curve25519 |
| 构建系统 | Cargo + Flutter | Rust编译 + Flutter打包 |

---

## 二、二次开发关键文件清单

### 2.1 移动端UI定制关键文件

| 文件路径 | 功能描述 | 定制优先级 |
|----------|----------|------------|
| `flutter/lib/main.dart` | 应用入口，UI路由分发 | ⭐⭐⭐ |
| `flutter/lib/mobile/pages/home_page.dart` | 移动端主页，设备列表 | ⭐⭐⭐ |
| `flutter/lib/mobile/pages/remote_page.dart` | 远程控制页面，工具栏 | ⭐⭐⭐ |
| `flutter/lib/mobile/pages/settings_page.dart` | 设置页面 | ⭐⭐ |
| `flutter/lib/models/peer_model.dart` | 设备数据模型 | ⭐⭐ |
| `flutter/pubspec.yaml` | 依赖管理与插件配置 | ⭐⭐⭐ |
| `flutter/lib/common.dart` | 主题配置，颜色常量 | ⭐⭐⭐ |
| `flutter/android/app/build.gradle` | Android构建配置 | ⭐⭐ |
| `flutter/ios/Runner/Info.plist` | iOS权限配置 | ⭐⭐ |

### 2.2 Flutter-Rust桥接关键文件

| 文件路径 | 功能描述 |
|----------|----------|
| `src/flutter_ffi.rs` | Rust端FFI接口定义 |
| `flutter/lib/generated_bridge.dart` | 自动生成的Dart绑定代码 |
| `flutter/lib/main.dart` | 导入并使用FFI绑定 |

### 2.3 安全相关关键文件

| 文件路径 | 功能描述 |
|----------|----------|
| `src/common.rs` | 加密算法实现 |
| `src/auth_2fa.rs` | 双因素认证 |
| `libs/hbb_common/src/config.rs` | 安全配置存储 |
| `src/ipc.rs` | IPC通信安全 |
| `src/ipc/auth.rs` | IPC授权验证 |

### 2.4 服务端部署关键文件

| 文件路径 | 功能描述 |
|----------|----------|
| `docker-compose.yml` | Docker编排配置 |
| `src/relay_server.rs` | 中继服务器实现 |
| `src/id_server.rs` | ID注册服务器实现 |

---

## 三、服务端部署方案（Docker-Compose配置）

### 3.1 基础部署架构

```
┌─────────────────────────────────────────────────────────────┐
│                        互联网                                │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   RustDesk服务器    │
                    │   (VPS/云主机)     │
                    ├───────────────────┤
                    │   hbbs容器         │  端口: 21114-21119
                    │   (ID/信令服务)    │
                    ├───────────────────┤
                    │   hbbr容器         │  端口: 21117, 21119
                    │   (中继服务)       │
                    └───────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
            ┌───────┴───────┐   ┌───────┴───────┐
            │  控制端客户端    │   │ 被控端客户端    │
            │  (手机/电脑)    │   │  (手机/电脑)   │
            └───────────────┘   └───────────────┘
```

### 3.2 推荐Docker-Compose配置

```yaml
# docker-compose.yml
version: '3.8'

services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs -r hbbr:21117
    volumes:
      - ./data:/root
    network_mode: "host"
    depends_on:
      - hbbr
    restart: unless-stopped
    environment:
      - ALWAYS_USE_RELAY=N  # N=优先P2P, Y=强制中继
      - ENCRYPTED_ONLY=1     # 启用加密连接验证

  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    network_mode: "host"
    restart: unless-stopped
```

### 3.3 防火墙端口要求

| 端口 | 协议 | 服务 | 用途 | 必需 |
|------|------|------|------|------|
| 21114 | TCP | hbbs | Web控制台 (仅Pro) | 否 |
| 21115 | TCP | hbbs | NAT类型测试 | 是 |
| 21116 | TCP/UDP | hbbs | ID注册/心跳/打洞 | 是 |
| 21117 | TCP | hbbr | 中继服务 | 是 |
| 21118 | TCP | hbbs | Web客户端支持 | 否 |
| 21119 | TCP | hbbr | Web客户端支持 | 否 |

### 3.4 部署步骤

```bash
# 1. 创建部署目录
mkdir -p /opt/rustdesk && cd /opt/rustdesk

# 2. 创建docker-compose.yml文件
vim docker-compose.yml
# 粘贴上述配置

# 3. 启动服务
docker compose up -d

# 4. 查看日志确认运行
docker logs hbbs
docker logs hbbr

# 5. 获取公钥（客户端配置需要）
cat ./data/id_ed25519.pub

# 6. 防火墙配置 (Ubuntu为例)
sudo ufw allow 21115:21119/tcp
sudo ufw allow 21116/udp
```

### 3.5 客户端配置

客户端需要配置以下信息连接自建服务器：

```
ID Server:      your-server-ip  (默认端口21116)
Relay Server:   your-server-ip  (默认端口21117)
API Server:     (留空或填入Pro版API地址)
Key:           id_ed25519.pub文件内容
```

---

## 四、移动端UI定制指南

### 4.1 添加AI工具快捷按钮

**方案设计：**
在远程控制页面的工具栏底部添加可自定义的AI工具快捷按钮区域。

**实现位置：** `flutter/lib/mobile/pages/remote_page.dart`

**核心代码示例：**

```dart
// 在_RemotePageState类中添加AI工具状态
class _RemotePageState extends State<RemotePage> {
  List<AIQuickAction> _aiQuickActions = [
    AIQuickAction(
      icon: Icons.auto_awesome,
      label: 'AI助手',
      action: () => _launchAIPanel(),
    ),
    AIQuickAction(
      icon: Icons.screenshot,
      label: '截图分析',
      action: () => _captureAndAnalyze(),
    ),
    // 可扩展更多快捷方式
  ];
  
  void _launchAIPanel() {
    // 实现AI面板启动逻辑
    showModalBottomSheet(
      context: context,
      builder: (context) => AIAssistantPanel(),
    );
  }
  
  // 在工具栏UI中添加AI按钮区域
  Widget _buildAIQuickBar() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _aiQuickActions.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final action = _aiQuickActions[index];
          return _AIQuickButton(
            icon: action.icon,
            label: action.label,
            onTap: action.action,
          );
        },
      ),
    );
  }
}
```

**AI面板组件示例：**

```dart
class AIAssistantPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖动条
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // AI功能列表
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('智能问答'),
                  subtitle: Text('针对当前屏幕内容提问'),
                  onTap: () => _startSmartQA(context),
                ),
                ListTile(
                  leading: Icon(Icons.text_fields),
                  title: Text('OCR识别'),
                  subtitle: Text('提取屏幕文字'),
                  onTap: () => _performOCR(context),
                ),
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('代码审查'),
                  subtitle: Text('分析远程代码'),
                  onTap: () => _analyzeCode(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4.2 主题定制 (Material 3)

RustDesk已开始支持Material Design 3，可通过以下方式定制：

```dart
// flutter/lib/common.dart
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(
    DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MyApp(
          lightColorScheme: lightDynamic ?? _defaultLight,
          darkColorScheme: darkDynamic ?? _defaultDark,
        );
      },
    ),
  );
}
```

### 4.3 手势操作定制

手势识别位于 `flutter/lib/mobile/gestures.dart`：

```dart
// 当前支持的触摸手势
// 单指点击/拖动 → 鼠标左键操作
// 双指缩放 → 远程桌面缩放
// 长按 → 鼠标右键
// 双指旋转 → 屏幕旋转（平板模式）

// 如需添加AI快捷手势，可扩展GestureRecognizer
class AIShortcutGestureRecognizer extends GestureRecognizer {
  // 检测三指点击触发AI菜单
  // 检测双击+长按组合手势
}
```

### 4.4 构建定制APK

```bash
# 克隆并进入flutter目录
cd flutter

# 安装依赖
flutter pub get

# 构建Release版本
flutter build apk --release --target-platform android-arm64,android-arm

# 或使用构建脚本
./build_android.sh
```

---

## 五、AI工具集成方案设计

### 5.1 集成架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    移动端Flutter应用                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ AI快捷按钮   │  │ 截图像素    │  │ 远程桌面画面纹理          │  │
│  │ 区域        │  │ 获取API     │  │ (Texture Renderer)      │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
│         │                │                      │                │
│         └────────────────┼──────────────────────┘                │
│                          ▼                                       │
│              ┌───────────────────┐                               │
│              │   AI Service      │                               │
│              │   (Flutter层)     │                               │
│              │                   │                               │
│              │ - 图像压缩        │                               │
│              │ - 请求组装        │                               │
│              │ - 响应渲染        │                               │
│              └─────────┬─────────┘                               │
└────────────────────────┼─────────────────────────────────────────┘
                         │ HTTP/WebSocket
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    后端AI服务层                                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    API Gateway                           │    │
│  │              (身份验证/限流/路由)                        │    │
│  └─────────────────────────────────────────────────────────┘    │
│              │                    │                    │        │
│              ▼                    ▼                    ▼        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   OCR识别服务    │  │   智能问答服务    │  │   代码分析服务    │  │
│  │  (PaddleOCR)    │  │  (RAG+LLM)      │  │  (CodeLLM)      │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 功能模块设计

| 功能 | 实现方式 | API接口设计 |
|------|----------|------------|
| 截图像素获取 | `textureRgbaRenderer.getPixels()` | 内部API，无需外部调用 |
| OCR文字识别 | 调云端OCR服务 | `POST /api/ai/ocr` |
| 智能问答 | RAG+LLM | `POST /api/ai/chat` |
| 代码分析 | CodeLLM | `POST /api/ai/code-review` |
| 屏幕内容摘要 | 视觉模型 | `POST /api/ai/summarize` |

### 5.3 数据安全考虑

```dart
// 传输前压缩敏感画面
Future<Uint8List> _compressScreenForAI(Uint8List rawPixels) async {
  // 1. 降低分辨率 (如从1920x1080降到960x540)
  // 2. 移除色彩敏感区域（如密码框）
  // 3. JPEG压缩减少传输大小
  // 4. 可选：本地差分隐私处理
}

// 传输加密
class SecureAIRequest {
  final String sessionToken;  // 临时会话令牌
  final String encryptedImage; // AES加密后的图像数据
  final String requestHash;   // 请求摘要防篡改
}
```

### 5.4 离线能力设计

```dart
// 轻量级离线AI功能（可选）
class OfflineAI {
  static bool _isModelDownloaded = false;
  
  // 本地OCR (使用tflite模型)
  Future<String> localOCR(Uint8List image) async {
    if (!_isModelDownloaded) {
      await _downloadModel();
    }
    return _runTFLiteInference(image);
  }
  
  // 本地关键词检测
  bool localKeywordDetect(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}
```

---

## 六、分步骤实施计划（Week by Week）

### Phase 1: 环境准备与架构熟悉 (Week 1-2)

| Day | 任务 | 交付物 |
|-----|------|--------|
| 1-2 | 搭建开发环境（Rust/Cargo/Flutter/Android SDK） | 完整的开发环境 |
| 3-4 | 克隆源码，分析目录结构 | 架构分析文档 |
| 5-7 | 理解Flutter-Rust FFI桥接机制 | FFI接口文档 |

**环境验证：**
```bash
# 验证Rust环境
rustc --version  # >= 1.70
cargo --version

# 验证Flutter环境
flutter --version
flutter doctor

# 验证Android SDK
echo $ANDROID_HOME
```

### Phase 2: 服务端部署 (Week 3-4)

| Day | 任务 | 交付物 |
|-----|------|--------|
| 8-10 | 准备VPS/云服务器 | 服务器就绪 |
| 11-12 | 部署Docker-Compose配置 | 运行中的hbbs/hbbr服务 |
| 13-14 | 配置防火墙，验证连接 | 服务端验证报告 |
| 15-16 | 测试客户端连接与P2P穿透 | 连接测试日志 |
| 17-20 | 安全加固配置（Key验证、加密） | 安全配置清单 |

**交付物：** 可用的私有RustDesk服务器

### Phase 3: 移动端定制开发 (Week 5-8)

| Week | Day | 任务 | 交付物 |
|------|-----|------|--------|
| Week 5 | 21-24 | 分析remote_page.dart结构 | UI修改方案 |
| Week 5 | 25-27 | 实现AI快捷按钮UI组件 | AIButtonWidget.dart |
| Week 6 | 28-31 | 集成到远程控制页面 | 修改后的remote_page.dart |
| Week 6 | 32-34 | 测试手势交互 | 测试报告 |
| Week 7 | 35-38 | 构建自动化脚本 | build_custom.sh |
| Week 7 | 39-42 | 打包测试（Debug APK） | 可安装的APK |
| Week 8 | 43-46 | 修复已知问题 | Bug修复记录 |
| Week 8 | 47-50 | 文档整理 | 开发文档 |

### Phase 4: AI服务集成 (Week 9-12)

| Week | 任务 | 交付物 |
|------|------|--------|
| Week 9 | 搭建AI后端服务框架 | 后端服务骨架 |
| Week 10 | 实现OCR识别接口 | OCR API |
| Week 11 | 实现智能问答接口 | Chat API |
| Week 12 | 集成到移动端，E2E测试 | 完整AI功能 |

### Phase 5: 安全加固与测试 (Week 13-14)

| Day | 任务 | 交付物 |
|-----|------|--------|
| 85-88 | 安全代码审计 | 安全审计报告 |
| 89-92 | 渗透测试 | 渗透测试报告 |
| 93-96 | 性能优化 | 性能测试报告 |
| 97-100 | 正式发布准备 | Release包 |

---

## 七、风险与注意事项

### 7.1 技术风险

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Flutter-Rust FFI接口变更 | 可能导致编译失败 | 跟踪官方更新，锁定版本 |
| 移动端纹理渲染兼容性 | 不同设备表现差异 | 多设备测试 |
| P2P穿透失败率 | 某些网络环境无法直连 | 完善的回退中继机制 |

### 7.2 法律合规

- RustDesk使用AGPL-3.0许可证
- 二次开发需遵守开源协议
- 商业使用建议咨询法律顾问

### 7.3 社区资源

- **Discord社区**: https://discord.gg/rustdesk
- **GitHub Issues**: https://github.com/rustdesk/rustdesk/issues
- **官方文档**: https://rustdesk.com/docs/

---

## 八、附录：参考项目

### 8.1 社区二次开发案例

| 项目 | 仓库地址 | 功能描述 |
|------|----------|----------|
| rustdesk-api | https://github.com/lejianwen/rustdesk-api | 自定义API服务器，含Web管理界面 |
| rustdesk-web-client | https://github.com/MonsieurBiche/rustdesk-web-client | Web客户端改进版 |
| RustDesk-RDP | https://github.com/sh13y/RustDesk-RDP | GitHub Actions自动化RDP |
| RustDesk深度定制 | CSDN专栏 | 白标部署、固件绑定等企业功能 |

### 8.2 关键依赖版本参考

```yaml
# flutter/pubspec.yaml 关键依赖
dependencies:
  flutter:
    sdk: flutter
  flutter_rust_bridge: ^1.80.0
  provider: ^6.0.0
  get: ^4.6.0
  
# 自定义渲染插件
texture_rgba_renderer:
  git:
    url: https://github.com/rustdesk-org/flutter_texture_rgba_renderer
flutter_gpu_texture_renderer:
  git:
    url: https://github.com/rustdesk-org/flutter_gpu_texture_renderer
```

---

**报告完成时间：** 2026年4月
**调研来源：** GitHub官方仓库、DeepWiki、CSDN技术博客、rustdesk.com官方文档
