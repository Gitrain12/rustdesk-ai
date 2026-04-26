# RustDesk远程控制APP - 移动端UI设计规范

## 1. Concept & Vision

一款融合了AI能力的远程控制APP，设计语言借鉴Ollama的极简现代风格。整体呈现深邃、科技感十足的专业工具感，通过精心设计的微交互和视觉层次，让远程控制操作变得直观且愉悦。核心体验强调"掌控感"——用户在任何界面都能清晰感知当前状态和可用操作。

## 2. Design Language

### 2.1 Aesthetic Direction
- **风格参考**：Ollama官网 - 极简深色科技风
- **核心理念**：克制、精致、功能优先
- **视觉特征**：大圆角卡片、微妙的玻璃态边框、柔和的光影过渡

### 2.2 Color Palette
```css
--bg-primary: #0d1117        /* 主背景 - 近乎纯黑的深蓝黑 */
--bg-secondary: #161b22      /* 卡片/面板背景 */
--bg-tertiary: #21262d       /* 悬浮/激活态背景 */
--bg-overlay: rgba(13, 17, 23, 0.95)  /* 遮罩层 */

--border-default: rgba(255, 255, 255, 0.1)    /* 默认边框 */
--border-hover: rgba(255, 255, 255, 0.2)       /* 悬浮边框 */
--border-focus: rgba(99, 102, 241, 0.5)        /* 聚焦边框 */

--text-primary: #e6edf3      /* 主文字 */
--text-secondary: #8b949e    /* 次要文字 */
--text-tertiary: #6e7681     /* 弱化文字 */

--accent-primary: #6366f1    /* 主强调色 - Indigo */
--accent-secondary: #8b5cf6  /* 次强调色 - Purple */
--accent-gradient: linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #a855f7 100%)

--status-online: #3fb950     /* 在线状态 - 绿色 */
--status-offline: #8b949e    /* 离线状态 - 灰色 */
--status-busy: #f0883e      /* 忙碌状态 - 橙色 */

--danger: #f85149           /* 危险/错误 */
--warning: #d29922          /* 警告 */
--success: #3fb950          /* 成功 */
```

### 2.3 Typography
- **主字体**：Inter (Google Fonts), -apple-system, BlinkMacSystemFont, sans-serif
- **等宽字体**：JetBrains Mono (用于代码/IP显示)
- **字号系统**：
  - 标题H1: 24px / 600
  - 标题H2: 18px / 600
  - 正文: 15px / 400
  - 辅助文字: 13px / 400
  - 小标签: 11px / 500

### 2.4 Spatial System
- **基础单位**：4px
- **间距序列**：4, 8, 12, 16, 20, 24, 32, 48px
- **卡片圆角**：12px（小卡片）/ 16px（大面板）/ 24px（模态框）
- **按钮圆角**：8px（常规）/ 12px（大按钮）
- **内边距**：卡片内边距 16px，列表项 12px 垂直 16px 水平

### 2.5 Motion Philosophy
- **原则**：快速响应，轻盈过渡
- **时长**：微交互 150ms / 页面切换 300ms / 模态展开 350ms
- **缓动**：cubic-bezier(0.4, 0, 0.2, 1) - 标准
- **关键动画**：
  - 页面切换：translateX + opacity组合
  - 卡片展开：height + rotate组合
  - 悬浮效果：scale(1.02) + 边框高亮
  - AI面板：slideUp + backdrop blur

### 2.6 Visual Assets
- **图标库**：Lucide Icons (通过CDN引入)
- **图标风格**：线条型，stroke-width: 1.5，尺寸 20-24px
- **装饰元素**：
  - 渐变光晕背景
  - 微妙的网格纹理
  - 玻璃态毛玻璃效果

## 3. Layout & Structure

### 3.1 页面架构
```
┌────────────────────────────┐
│      Status Bar (系统)      │
├────────────────────────────┤
│                            │
│                            │
│       Main Content         │
│       (各页面内容区)         │
│                            │
│                            │
├────────────────────────────┤
│      Bottom Navigation     │
│        (底部导航栏)          │
└────────────────────────────┘
```

### 3.2 页面列表
1. **首页/设备列表** - 默认入口
2. **远程桌面** - 全屏连接画面
3. **AI快捷面板** - 悬浮覆盖层
4. **设置页** - 配置项列表

### 3.3 响应式策略
- **设计基准**：375px 宽度（iPhone SE/8）
- **安全区域**：适配刘海屏底部home indicator
- **最大宽度**：428px（覆盖主流大屏手机）

## 4. Features & Interactions

### 4.1 设备列表页
- **设备卡片**：
  - 点击整卡 → 展开显示更多操作按钮
  - 展开状态点击"连接" → 跳转远程桌面
  - "更多"按钮 → 显示下拉菜单（编辑、重命名、删除）
- **状态指示**：
  - 🟢 在线：绿色圆点 + "在线"文字
  - ⚫ 离线：灰色圆点 + "离线"文字
  - 🟠 忙碌：橙色圆点 + "连接中"
- **添加设备**：底部固定按钮，点击显示扫码/手动输入弹窗

### 4.2 远程桌面页
- **顶部栏**：
  - 返回按钮 ← → 返回设备列表
  - 设备名称（居中）
  - 设置⚙️ + 全屏⛶ 按钮
- **桌面区域**：
  - 自适应屏幕比例
  - 支持双指缩放
  - 点击唤出虚拟鼠标
- **底部工具栏**：
  - 🖱️ 鼠标模式
  - ⌨️ 键盘唤起
  - 🤖 AI助手（展开AI面板）
  - 📁 文件传输
  - 📋 剪贴板
  - ⚡ 快捷命令

### 4.3 AI快捷面板
- **触发方式**：点击🤖按钮或从底部上滑
- **收起方式**：点击遮罩 / 下滑 / 点击关闭
- **功能按钮**：
  - 网格布局 3×2 或更多
  - 每个按钮带图标 + 文字
  - 点击后发送到选定的AI应用
- **底部操作**：
  - "发送到豆包" 按钮
  - "发送到Trae" 按钮
  - 可切换目标应用

### 4.4 设置页
- **分组列表**：
  - 连接设置（画质、帧率、音频）
  - 安全设置（密码、生物识别）
  - 通知设置
  - 账户管理
  - 关于与反馈
- **每项交互**：
  - 点击切换 → Toggle开关
  - 点击跳转 → 右箭头 + 详情页

## 5. Component Inventory

### 5.1 DeviceCard 设备卡片
```
States:
- Default: 收起状态，显示基础信息
- Expanded: 展开状态，显示操作按钮
- Loading: 连接中，显示loading动画
- Disabled: 设备不可用，置灰显示
```

### 5.2 BottomNav 底部导航
```
States:
- Default: 未选中，图标+文字灰色
- Active: 选中，图标+文字高亮，顶部指示条
- Badge: 带红点提示（如有新文件）
```

### 5.3 ActionButton 操作按钮
```
Variants:
- Primary: 渐变背景，白色文字
- Secondary: 透明背景，边框，白色文字
- Ghost: 无边框，hover显示背景
- Icon: 圆形，仅图标

States:
- Default / Hover / Active / Disabled / Loading
```

### 5.4 Toggle 开关
```
States:
- Off: 灰色轨道
- On: 蓝色轨道 + 白色滑块
- Disabled: 降低透明度
```

### 5.5 AIPanel AI面板
```
States:
- Hidden: 完全隐藏
- Visible: 滑入视图
- Loading: 功能执行中的loading态
```

### 5.6 DesktopViewer 远程桌面
```
States:
- Connecting: 连接中动画
- Connected: 正常显示
- Paused: 暂停画面
- Error: 错误提示
```

## 6. Technical Approach

### 6.1 技术栈
- **框架**：纯HTML5 + CSS3 + Vanilla JavaScript
- **图标**：Lucide Icons CDN
- **字体**：Google Fonts (Inter, JetBrains Mono)
- **无外部依赖**：单文件完整运行

### 6.2 CSS架构
```css
/* CSS变量定义区 */
/* 基础重置 */
/* 布局组件 */
/* 页面样式 */
/* 动画定义 */
/* 响应式适配 */
```

### 6.3 JavaScript模块
```javascript
// 页面路由管理
// 设备卡片交互
// AI面板控制
// 主题切换（如需要）
// 页面切换动画
```

### 6.4 性能优化
- CSS变量减少重复样式
- transform/opacity实现动画（GPU加速）
- 事件委托优化列表交互
- 懒加载非首屏资源
