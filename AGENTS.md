# AGENTS.md

这份文件用于给后续接手 RepoLens AI 的 AI 编程 Agent 提供项目背景和开发约束。新的 Codex 项目线程应优先阅读本文件，再开始修改代码。

## 项目概述

RepoLens AI 是一个无后端、跨平台的 Flutter 应用，用于发现和分析 GitHub 上的 AI 工具项目。

应用应支持：

- 运行在 Windows x64、macOS、Android 和 iOS。
- 直接从 GitHub API 拉取 AI 相关仓库数据。
- 使用用户自定义的 AI 供应商和用户选择的模型进行结构化分析。
- 在本地保存项目数据、分析结果、图表、收藏和导出记录。
- 帮助用户判断某个 GitHub AI 工具项目适合用公司哪些 API 能力实现、增强或复用。
- 支持导出数据、图表和报告。
- 桌面端提供本地 MCP 接口，让 AI 编程工具可以把 RepoLens AI 的数据导入公司项目。

## 不可变产品决策

- 默认保持 local-first 和无后端架构。
- 除非用户明确要求，不要添加托管后端、远程数据库或云端任务服务。
- 不要硬编码公司 API Key、GitHub Token 或 AI 供应商密钥。
- 用户密钥必须保存在安全存储中，不能明文放入 SQLite。
- AI 供应商必须支持用户自定义。
- 推荐 AI API 为 TokenMix，Base URL 为 `https://api.tokenmix.ai/v1`，采用 OpenAI-compatible 协议；不要把 TokenMix API Key 写入代码或数据库。
- 应在产品内引导用户去 `https://tokenmix.ai` 注册并创建 API Key。TokenMix 接入多家模型，适合作为默认多模型网关。
- 模型选择必须由用户控制，不能在代码中固定死。
- MCP 服务只面向桌面端本地开发流程，移动端不需要托管 MCP 服务。
- 应支持多语言界面适配；用户选择的显示语言也应影响 AI 分析提示词语言。

## 推荐技术栈

- Flutter：应用框架。
- Riverpod：状态管理。
- Dio：HTTP 请求。
- Drift + SQLite：本地数据存储。
- flutter_secure_storage：敏感凭据存储。
- freezed + json_serializable：不可变数据模型和结构化 AI 输出。
- fl_chart：图表。
- pdf、csv、path_provider：导出流程。
- share_plus、file_picker 等原生插件仅在功能实际需要时再引入；未使用时不要保留，避免增大包体积或触发 iOS/macOS 构建警告。
- Kyant0/AndroidLiquidGlass：Android 端默认液态玻璃效果库。
- TypeScript MCP sidecar：桌面端 AI 编程工具集成。

不要轻易引入与以上技术栈竞争的状态管理、网络请求或持久化框架，除非有明确且充分的理由。

## 跨平台视觉要求

- Android 端默认使用 [Kyant0/AndroidLiquidGlass](https://github.com/Kyant0/AndroidLiquidGlass) 最新可构建版本实现液态玻璃视觉效果。
- Android 端应允许用户在液态玻璃视觉和 Jetpack Material 3 风格之间选择；默认选项为液态玻璃。
- iOS 和 macOS 端默认并强制使用 Apple 原生液态玻璃或原生视觉材质，不要被 Material 3 实心 surface 覆盖。
- 不要使用 Flutter 自绘的 `BackdropFilter` / `CustomPaint` 玻璃面板长期模拟液态玻璃；Apple 平台优先 UIKit/AppKit 原生 view，Android 优先 Kyant0/AndroidLiquidGlass 原生 Compose 组件。
- 保持 Flutter 主应用架构；如需接入 Android 原生或 Compose Multiplatform 能力，应只把它作为平台视觉能力补充，避免把业务逻辑散落到原生层。

## 多语言与提示词

- 应至少支持简体中文、英文和跟随系统语言。
- UI 文案应集中管理，避免在页面 Widget 中长期散落硬编码文案。
- AI 分析服务应根据用户选择的语言使用对应语言的 system prompt 和 user prompt。
- 结构化 AI 输出的 JSON 字段名、导出 Schema 和公共 API 字段名保持英文；自然语言字段值跟随用户选择的语言。

## 建议模块结构

随着项目增长，必须采用按功能、模块、页面拆分的结构；不要把跨平台逻辑、页面、组件、模型长期堆在单个大文件里。新功能优先拆到对应 feature/module/page/component 文件中，只有稳定的小型 glue code 才留在入口文件。

```text
lib/
  app/
    providers.dart
    app_controller.dart
    app_state.dart
    native_shell_bridge.dart
  core/
    i18n/
    models/
    services/
  features/
    github_discovery/
      pages/
      widgets/
      services/
    ai_analysis/
      pages/
      widgets/
      services/
    ai_providers/
      models/
      pages/
      widgets/
      services/
    project_library/
      pages/
      widgets/
    charts/
    exports/
    sharing/
    settings/
      pages/
      widgets/
  data/
  ui/
    theme/
    widgets/
```

原生平台代码也要拆分，不能把页面、模型、状态、组件全部写进一个 Swift/Kotlin 文件：

```text
android/app/src/main/kotlin/.../
  shell/
  state/
  models/
  pages/
  components/
  theme/

ios/Runner/
  Shell/
  State/
  Models/
  Pages/
  Components/

macos/Runner/
  Shell/
  State/
  Models/
  Pages/
  Components/
```

Android Compose 组件、Kyant Liquid Glass 组件、底部导航、输入控件、设置页、分析页、项目页应按功能放入包；iOS/macOS SwiftUI 的 shell、页面、组件、模型、状态也应拆分到对应文件夹。后续如果发现某个原生文件超过合理职责边界，应优先拆分再继续追加功能。

桌面端 MCP 代码如有需要，可放在 Flutter 项目外的工具目录：

```text
tools/mcp_sidecar/
```

## 领域模型指导

优先使用明确的结构化模型，不要长期依赖松散的 `Map` 或未类型化 JSON。

核心概念：

- `AiToolProject`
- `AiToolAnalysis`
- `AiProviderConfig`
- `AiModelConfig`
- `AnalysisDimension`
- `TrendSnapshot`
- `ExportBundle`

AI 分析结果必须尽量落成可校验的结构化数据，而不是只保存自然语言文本。典型分析结果应包含分类、摘要、使用场景、技术栈、风险、评分、许可证信息、维护活跃度、多维评估、架构观察、质量信号、安全注意、业务适配、建议和下一步行动。不要再把“公司 API 建议”作为主结果结构。

## AI 供应商设计

AI Provider 应采用适配器模式。

预期支持的供应商类型：

- TokenMix 推荐 API，默认启用，OpenAI-compatible Base URL 固定为 `https://api.tokenmix.ai/v1`。
- OpenAI-compatible endpoint。
- Anthropic。
- Gemini。
- DeepSeek。
- Volcengine / Doubao。
- Ollama。
- Custom endpoint。

默认应内置多家供应商模板并预填 Base URL，默认选中 TokenMix。TokenMix 是公司默认多模型网关，用户只需填 TokenMix API Key 并选择模型；模型列表应优先通过供应商 `/models` 或对应 SDK 拉取。第一阶段应优先实现 OpenAI-compatible 自定义端点，因为它可以覆盖很多厂商。

内置供应商模板至少包含：

- TokenMix：`https://api.tokenmix.ai/v1`，OpenAI-compatible，默认 Provider。
- OpenAI：`https://api.openai.com/v1`。
- DeepSeek：`https://api.deepseek.com`。
- Anthropic：`https://api.anthropic.com`。
- Gemini OpenAI-compatible：`https://generativelanguage.googleapis.com/v1beta/openai`。
- Xiaomi MiMo：`https://api.xiaomimimo.com/v1`，OpenAI-compatible。
- Xiaomi MiMo Token Plan CN：`https://token-plan-cn.xiaomimimo.com/v1`，OpenAI-compatible。
- Xiaomi MiMo Token Plan SGP：`https://token-plan-sgp.xiaomimimo.com/v1`，OpenAI-compatible。
- Xiaomi MiMo Token Plan AMS：`https://token-plan-ams.xiaomimimo.com/v1`，OpenAI-compatible。

Provider 设置应包含：

- 供应商名称。
- Base URL。
- API Key 引用。
- 可用模型列表。
- 默认模型。
- 上下文长度。
- temperature。
- max output tokens。
- 是否支持结构化输出。
- 是否支持 tool calling。

## GitHub 发现流程

应用应从客户端直接调用 GitHub。需要提高额度时，使用用户自己提供的 GitHub Token。

常用搜索维度：

- 时间范围：今天、本周、自定义时间。
- 关键词：AI、agent、LLM、RAG、MCP、workflow、chatbot、image、audio、coding。
- 过滤条件：语言、stars、forks、topics、pushed date、created date。

拉取结果应本地缓存，并按仓库 full name 去重。保留足够的原始元数据，便于后续重新分析。

## 导出和分享

一等导出目标：

- JSON：供 MCP 和程序化导入使用。
- CSV：供表格软件和运营分析使用。
- Markdown：供报告、文档、GitHub、飞书、Notion 等使用。
- PDF：供正式报告分享。
- PNG：供图表分享。
- TypeScript module：供公司前端项目直接导入。

导出结果应基于结构化本地数据生成，不要通过抓取渲染后的 UI 来拼数据。

## MCP Sidecar

桌面端 MCP sidecar 应把 RepoLens AI 的本地数据暴露给 AI 编程工具。

计划资源：

```text
aitools://projects
aitools://projects/{owner}/{repo}
aitools://analysis/{owner}/{repo}
aitools://company-api/mappings
```

计划工具：

```text
search_ai_tools
get_ai_tool_detail
get_ai_tool_analysis
generate_company_api_mapping
export_ai_tools_json
generate_import_module
write_import_file
```

`write_import_file` 写入其他项目文件前，必须要求用户在 App 中显式打开允许写入的设置。

## 开发命令

优先使用当前机器已配置好的 Flutter SDK。如果 FVM 可用，可以使用：

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run -d macos
```

如果 shell 已经能通过 FVM 解析 `flutter`，也可以直接使用：

```bash
flutter pub get
flutter analyze
flutter test
flutter devices
```

添加生成式模型后运行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 打包体积要求

- 不要用 debug APK 评估体积；debug 包会包含调试符号、多 ABI 和验证库，明显大于真实分发包。
- Android 直接分发 APK 时优先使用 `fvm flutter build apk --release --split-per-abi`。
- Android 商店分发优先使用 `fvm flutter build appbundle --release`，AAB 本身包含多 ABI，实际下载体积由商店拆分后决定。
- release 构建应保持 R8 minify、resource shrink 和 native library 压缩开启，除非有明确运行时问题。
- 未使用的 Flutter 插件不要保留在 `pubspec.yaml` 中；它们会注册原生代码、增大包体积，并可能带来平台构建警告。

## 编码标准

- 遵循 Flutter 和 Dart 的常规代码风格。
- 保持强类型。
- 不要把密钥写入日志、导出文件或明文存储。
- GitHub 搜索、AI 分析、导出生成、设置管理应拆成小而可测的服务。
- 不要把网络、存储和 UI 逻辑混在 Widget 里。
- 为解析器、结构化 AI 输出校验、Provider 适配器和导出生成添加聚焦测试。
- UI 文案应简洁，偏产品表达。

## 沟通约定

项目 owner 主要使用中文沟通。后续 Agent 的聊天说明优先使用简洁中文；代码标识符、公共 API、导出 Schema 和开发者文档中的字段名保持清晰英文。
