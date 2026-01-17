# Spindle

一款使用 Flutter 构建的跨平台本地音乐播放器，支持桌面端和移动端。

## 功能特性

### 音乐播放

- 支持多种音频格式：MP3、FLAC、WAV、AAC、M4A、OGG、WMA、AIFF、ALAC
- 播放控制：播放/暂停、上一曲/下一曲、进度拖动、音量调节
- 播放模式：顺序播放、单曲循环、列表循环、随机播放
- 播放队列管理：添加、移除、拖拽排序、清空队列
- 后台播放：支持锁屏播放和系统媒体控制
- 键盘快捷键：空格键播放/暂停

### 音乐库管理

- 文件夹扫描：递归扫描指定文件夹，自动提取音频文件
- 元数据提取：自动读取标题、艺术家、专辑、时长、比特率等信息
- 专辑封面：自动提取并缓存专辑封面图片
- 收藏功能：标记喜欢的歌曲，快速访问收藏列表
- 搜索功能：按标题、艺术家、专辑搜索歌曲
- 播放历史：记录播放次数和最近播放时间

### 歌词功能

- 支持 LRC 格式的同步歌词
- 支持纯文本歌词
- 歌词自动滚动，高亮当前行
- 内置歌词编辑器，支持插入时间戳

### 元数据编辑

- 编辑歌曲标题、艺术家、专辑
- 编辑曲目编号、年份、流派
- 将修改写入音频文件

### 平台特性

**桌面端：**
- 窗口管理：自定义窗口大小，记住窗口位置
- 系统托盘：最小化到托盘
- macOS 安全书签：持久化文件夹访问权限

**移动端：**
- 响应式布局适配
- iOS 支持从文件 App 导入音乐
- Android 适配各版本存储权限

## 支持平台

| 平台 | 支持状态 |
|------|----------|
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |
| Android | ✅ |
| iOS | ✅ |

## 技术栈

- **框架**：Flutter
- **状态管理**：Signals
- **依赖注入**：GetIt
- **路由**：AutoRoute
- **数据库**：SQLite (Laconic ORM)
- **音频播放**：just_audio + audio_service
- **元数据**：metadata_god

## 开始使用

### 环境要求

- Flutter SDK 3.10.0 或更高版本
- Dart SDK 3.10.0 或更高版本

### 构建运行

```bash
# 克隆仓库
git clone https://github.com/CalsRanna/spindle.git
cd spindle

# 安装依赖
flutter pub get

# 生成路由代码
dart run build_runner:build

# 运行应用
flutter run
```

### 打包发布

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux

# Android
flutter build apk

# iOS
flutter build ios
```

## 使用说明

1. **导入音乐**：进入导入页面，添加音乐文件夹或直接选择音频文件
2. **浏览音乐库**：在音乐库页面查看所有歌曲，支持搜索和筛选
3. **播放音乐**：点击歌曲开始播放，使用播放器控制播放
4. **管理收藏**：点击心形图标收藏歌曲，在收藏页面查看
5. **编辑信息**：长按歌曲进入编辑页面，修改元数据或歌词

## 项目结构

```
lib/
├── database/          # 数据库配置和迁移
├── di.dart            # 依赖注入配置
├── entity/            # 数据模型
├── page/              # UI 页面
│   ├── desktop/       # 桌面端页面
│   └── mobile/        # 移动端页面
├── repository/        # 数据访问层
├── router/            # 路由配置
├── service/           # 业务逻辑服务
├── util/              # 工具类
└── widget/            # 可复用组件
```

## 许可证

MIT License
