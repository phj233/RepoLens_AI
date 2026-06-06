# RepoLens AI

RepoLens AI 是一个无后端、跨平台的 Flutter 应用，用于发现、分析、可视化、导出和复用 GitHub 上的 AI 工具项目。

它可以帮助用户按指定时间范围收集 GitHub 上的 AI 相关仓库，通过用户自定义的 AI 供应商和模型进行结构化分析，生成趋势图表、报告和数据集，并引导用户了解这些项目适合接入公司哪些 API 能力。桌面端还会预留本地 MCP 接口，方便 Codex、Cursor、IDE Agent 等 AI 编程工具在公司项目中导入已分析的数据。

## 产品方向

- 按天、按周或自定义时间范围发现 GitHub AI 工具项目。
- 支持用户自定义 AI 供应商，并选择不同模型进行分析。
- 本地保存结构化项目数据，不依赖云端后端服务。
- 可视化语言分布、项目分类、star 趋势、公司 API 匹配度等数据。
- 支持导出 JSON、CSV、Markdown、PDF、PNG 图表和 TypeScript 模块。
- 支持通过系统分享能力或平台连接器分享导出结果。
- 桌面端提供本地 MCP sidecar，方便 AI 编程工具读取和导入数据。

## 架构

```text
Flutter App
  -> GitHub REST / GraphQL APIs
  -> 本地缓存与结构化存储
  -> AI Provider 适配器
  -> 分析、图表、导出、分享
  -> 桌面端 MCP sidecar
  -> 公司项目导入流程
```

第一阶段应保持 local-first：

- 不引入托管后端，除非产品方向明确变化。
- 不在 App 中硬编码公司级 API Key 或 AI 供应商密钥。
- 用户的敏感凭据必须保存到安全存储中。
- 项目数据、分析结果、图表数据和导出记录保存在本地数据库中。

## 计划技术栈

- Flutter：支持 Windows x64、macOS、Android、iOS。
- Riverpod：状态管理。
- Dio：网络请求。
- Drift + SQLite：本地结构化数据存储。
- flutter_secure_storage：保存 API Key 和敏感配置。
- freezed + json_serializable：结构化 AI 数据模型。
- fl_chart：应用内图表。
- share_plus：系统分享。
- pdf / csv / file_picker / path_provider：导出能力。
- TypeScript MCP sidecar：桌面端 AI 编程工具集成。

## 核心数据概念

- `AiToolProject`：标准化后的 GitHub 仓库元数据。
- `AiToolAnalysis`：AI 生成的分类、摘要、评分、风险和使用场景。
- `AiProviderConfig`：用户配置的 AI 供应商和模型设置。
- `CompanyApiMapping`：项目与公司 API 能力的匹配建议。
- `TrendSnapshot`：每日或每周趋势快照。
- `ExportBundle`：生成的 JSON、CSV、Markdown、PDF、PNG 或 TypeScript 导出结果。

## 开发

项目由 Flutter 创建。当前机器已通过 FVM 管理 Flutter SDK，如果 shell 中已能直接识别 `flutter`，可以直接使用下面的命令。

```bash
flutter doctor
flutter devices
flutter pub get
flutter run -d macos
flutter run -d ios
flutter run -d android
```

添加需要代码生成的数据模型后，运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

提交或交接代码前，至少运行：

```bash
flutter analyze
flutter test
```

## 自动发版

仓库已配置 GitHub Actions 自动发版流程：推送 `v*.*.*` 格式的标签会触发构建并创建 GitHub Release，也可以在 GitHub Actions 页面手动运行 `Release` workflow。

```bash
git tag v1.0.0
git push origin v1.0.0
```

Release workflow 会构建并上传 Android APK/AAB、macOS、Linux、Windows 产物；iOS 当前输出 unsigned app archive，后续可接入 Apple 签名和 TestFlight 流程。

Android 正式签名是可选配置。需要正式签名时，在 GitHub 仓库 Secrets 中添加：

- `ANDROID_KEYSTORE_BASE64`：release keystore 的 base64 内容。
- `ANDROID_KEYSTORE_PASSWORD`：keystore 密码。
- `ANDROID_KEY_ALIAS`：key alias。
- `ANDROID_KEY_PASSWORD`：key 密码。

未配置这些 secrets 时，CI 仍会生成 release 构建检查产物，但 Android 会沿用 debug signing config，不能作为正式商店包使用。

## 当前状态

当前项目已经具备 RepoLens AI 的主要本地应用骨架：GitHub 项目发现、项目库、AI 供应商配置、结构化分析、导出记录、多语言、深色模式，以及 iOS/macOS 原生视觉材质和 Android Kyant0 Liquid Glass 原生组件接入。后续适合继续完善真实发版签名、桌面 MCP sidecar 和更完整的导出分享流程。
