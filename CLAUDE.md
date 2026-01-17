# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Spindle 是一个使用 Flutter 构建的跨平台本地音乐播放器。支持桌面端（Windows、macOS、Linux）和移动端（Android、iOS），两个平台有各自独立的 UI 实现。

## 开发命令

```bash
# 安装依赖
flutter pub get

# 生成代码（路由等）- 修改路由后必须执行
dart run build_runner:build

# 开发时监听模式自动生成代码
dart run build_runner:watch

# 运行应用
flutter run

# 运行测试
flutter test

# 代码分析
flutter analyze

# 格式化代码
dart format lib/

# 应用 lint 修复
dart fix --apply
```

## 架构

### 分层结构
- **entity/** - 数据模型，包含 `fromMap`/`toMap`/`copyWith` 方法
- **repository/** - 数据访问层，使用 Laconic ORM 操作 SQLite
- **service/** - 业务逻辑（AudioService、MetadataService、BookmarkService）
- **page/** - UI 页面，按平台分离：
  - `page/desktop/` - 桌面端页面及其 ViewModel
  - `page/mobile/` - 移动端页面及其 ViewModel
- **widget/** - 共享的可复用 UI 组件
- **util/** - 工具类（主题、日志、窗口管理）

### 核心模式
- **状态管理**：使用 Signals 包实现 ViewModel 中的响应式状态
- **依赖注入**：GetIt，配置在 `lib/di.dart`
- **路由**：AutoRoute，根据平台自动选择路由树，定义在 `lib/router/app_router.dart`
- **数据库**：SQLite，通过 Laconic ORM（git 依赖自 CalsRanna/laconic）

### 平台检测
路由和功能根据 `Platform.isWindows || Platform.isMacOS || Platform.isLinux` 判断桌面端或移动端行为。

### ViewModel
ViewModel 与页面放在一起（如 `page/desktop/library/library_view_model.dart`）。使用 Signals 实现响应式属性，在 `lib/di.dart` 中注册。

## 数据库

- SQLite 数据库存储在应用支持目录，文件名为 `spindle.db`
- 迁移文件在 `lib/database/migration/`，使用时间戳命名（如 `migration_202601161200.dart`）
- 主要表：`songs`、`folder_paths`、`play_history`、`migrations`

## 添加新功能

1. 如需新数据模型，在 `lib/entity/` 创建实体
2. 在 `lib/repository/` 添加数据访问仓库
3. 在 `lib/page/desktop/` 和 `lib/page/mobile/` 分别创建桌面端和移动端页面
4. 在 `lib/router/app_router.dart` 为两个平台添加路由
5. 执行 `dart run build_runner:build` 重新生成路由代码
6. 在 `lib/di.dart` 注册 ViewModel

## macOS 特殊处理

使用 `macos_secure_bookmarks` 包持久化文件夹访问权限，确保应用重启后仍可访问用户选择的文件夹。BookmarkService 负责保存和恢复这些书签。
