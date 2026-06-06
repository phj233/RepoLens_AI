import Cocoa
import FlutterMacOS
import SwiftUI

struct RepoLensMacDashboardPage: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    VStack(alignment: .leading, spacing: 16) {
      RepoLensPageHeader(
        title: snapshot.strings.discovery,
        subtitle: snapshot.strings.discoverySubtitle,
        action: RepoLensNativeActionButton(
          title: snapshot.isDiscovering ? snapshot.strings.loading : snapshot.strings.discover,
          systemImage: "scope",
          prominent: true
        ) {
          shellState.discover()
        }
      )
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 12)], spacing: 12) {
        RepoLensMetricPill(title: snapshot.strings.projects, value: "\(snapshot.projects.count)", systemImage: "folder")
        RepoLensMetricPill(title: snapshot.strings.stars, value: snapshot.totalStars.compactString, systemImage: "star")
        RepoLensMetricPill(title: snapshot.strings.analyses, value: "\(snapshot.analyses.count)", systemImage: "sparkles")
        RepoLensMetricPill(title: snapshot.strings.averageScore, value: String(format: "%.1f", snapshot.averageScore), systemImage: "speedometer")
      }
      RepoLensMacFilterPanel(shellState: shellState)
      RepoLensMacProjectListPanel(shellState: shellState, limit: 8)
    }
  }
}

struct RepoLensMacFilterPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  @State private var keyword: String
  @State private var dateRange: String
  @State private var language: String
  @State private var minStars: Double

  init(shellState: RepoLensNativeShellState) {
    self.shellState = shellState
    let filters = shellState.snapshot.filters
    _keyword = State(initialValue: filters.keyword)
    _dateRange = State(initialValue: filters.dateRange)
    _language = State(initialValue: filters.language)
    _minStars = State(initialValue: Double(filters.minStars))
  }

  var body: some View {
    let strings = shellState.snapshot.strings
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Text(strings.searchFilters)
          .font(.headline)
        TextField(strings.keyword, text: $keyword)
          .textFieldStyle(.roundedBorder)
        HStack {
          Picker(strings.date, selection: $dateRange) {
            Text(strings.today).tag("Today")
            Text(strings.thisWeek).tag("This week")
            Text(strings.any).tag("Any")
          }
          Picker(strings.language, selection: $language) {
            Text(strings.any).tag("Any")
            Text("Dart").tag("Dart")
            Text("Python").tag("Python")
            Text("TypeScript").tag("TypeScript")
            Text("Kotlin").tag("Kotlin")
            Text("Swift").tag("Swift")
          }
        }
        HStack {
          Text("\(strings.minStars): \(Int(minStars))")
            .foregroundColor(.secondary)
          Slider(value: $minStars, in: 0...1000, step: 5)
          RepoLensNativeActionButton(title: strings.search, systemImage: "magnifyingglass", prominent: true) {
            shellState.updateFilters(
              keyword: keyword,
              dateRange: dateRange,
              language: language,
              minStars: Int(minStars)
            )
            shellState.discover()
          }
        }
      }
    }
  }
}

struct RepoLensMacProjectListPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  var limit: Int?
  var searchQuery = ""

  var body: some View {
    let snapshot = shellState.snapshot
    let projects = filteredProjects(snapshot.projects, query: searchQuery)
    let visibleProjects = Array(projects.prefix(limit ?? projects.count))
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Text(snapshot.strings.projects)
          .font(.headline)
        if snapshot.projects.isEmpty {
          Text(snapshot.strings.emptyProjects)
            .foregroundColor(.secondary)
        } else if visibleProjects.isEmpty {
          Text(snapshot.strings.noProjectSearchResults)
            .foregroundColor(.secondary)
        } else {
          ForEach(visibleProjects) { project in
            Button {
              shellState.openProjectDetail(project.fullName)
            } label: {
              RepoLensMacProjectRow(
                project: project,
                isSelected: project.fullName == snapshot.selectedProjectFullName
              )
            }
            .buttonStyle(.plain)
            Divider()
          }
        }
      }
    }
  }

  private func filteredProjects(
    _ projects: [RepoLensNativeProject],
    query: String
  ) -> [RepoLensNativeProject] {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !normalizedQuery.isEmpty else {
      return projects
    }
    return projects.filter { project in
      let searchable = (
        project.fullName + " " +
        project.description + " " +
        project.language + " " +
        project.license + " " +
        project.topics.joined(separator: " ")
      ).lowercased()
      return searchable.contains(normalizedQuery)
    }
  }
}

struct RepoLensMacProjectRow: View {
  let project: RepoLensNativeProject
  let isSelected: Bool
  @Environment(\.repoLensTokens) private var tokens

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: project.isFavorite ? "star.fill" : "folder")
        .foregroundColor(project.isFavorite ? tokens.warning : tokens.accent)
      VStack(alignment: .leading, spacing: 5) {
        Text(project.fullName)
          .font(.subheadline.weight(.semibold))
          .foregroundColor(isSelected ? tokens.accent : tokens.textPrimary)
        if !project.description.isEmpty {
          Text(project.description)
            .font(.footnote)
            .foregroundColor(.secondary)
            .lineLimit(2)
        }
        HStack {
          RepoLensNativeChip(text: project.language, systemImage: "chevron.left.forwardslash.chevron.right")
          RepoLensNativeChip(text: project.stars.compactString, systemImage: "star")
        }
      }
      Spacer()
    }
    .padding(.vertical, 6)
  }
}

struct RepoLensMacProjectsPage: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  @State private var projectQuery = ""

  var body: some View {
    let snapshot = shellState.snapshot
    if snapshot.projectDetailOpen {
      RepoLensMacProjectDetailPage(shellState: shellState)
    } else {
      VStack(alignment: .leading, spacing: 16) {
        RepoLensPageHeader(
          title: snapshot.strings.projectLibrary,
          subtitle: snapshot.strings.projectLibrarySubtitle,
          action: RepoLensNativeActionButton(title: snapshot.strings.refresh, systemImage: "arrow.clockwise") {
            shellState.discover()
          }
        )
        RepoLensNativeGlassPanel {
          TextField(snapshot.strings.projectSearch, text: $projectQuery)
        }
        RepoLensMacProjectListPanel(
          shellState: shellState,
          searchQuery: projectQuery
        )
      }
    }
  }
}

struct RepoLensMacProjectDetailPage: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    VStack(alignment: .leading, spacing: 16) {
      RepoLensPageHeader(
        title: snapshot.selectedProject?.fullName ?? snapshot.strings.projectDetail,
        subtitle: snapshot.selectedProject?.description ?? snapshot.strings.noProjectSelected,
        action: RepoLensNativeActionButton(
          title: snapshot.strings.backToProjects,
          systemImage: "chevron.left"
        ) {
          shellState.closeProjectDetail()
        }
      )
      RepoLensMacProjectDetailPanel(shellState: shellState)
    }
  }
}

struct RepoLensMacProjectDetailPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    RepoLensNativeGlassPanel {
      if let project = snapshot.selectedProject {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Text(project.fullName)
              .font(.headline)
            Spacer()
            Button {
              shellState.toggleFavorite(project.fullName)
            } label: {
              Image(systemName: project.isFavorite ? "star.fill" : "star")
            }
          }
          Text(project.description)
            .foregroundColor(.secondary)
          RepoLensDetailLine(label: "URL", value: project.htmlUrl)
          RepoLensDetailLine(label: "Language", value: project.language)
          RepoLensDetailLine(label: "License", value: project.license)
          RepoLensDetailLine(label: "Stars", value: "\(project.stars)")
          RepoLensDetailLine(label: "Forks", value: "\(project.forks)")
          RepoLensDetailLine(label: snapshot.strings.pushed, value: project.pushedAtDisplay)
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 6)], alignment: .leading, spacing: 6) {
            ForEach(project.topics.prefix(10), id: \.self) { topic in
              RepoLensNativeChip(text: topic)
            }
          }
        }
      } else {
        Text(snapshot.strings.noProjectSelected)
          .foregroundColor(.secondary)
      }
    }
  }
}

struct RepoLensMacFloatingAnalysisConfig: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  @State private var expanded = false

  var body: some View {
    let snapshot = shellState.snapshot
    if expanded {
      RepoLensNativeGlassPanel {
        VStack(alignment: .leading, spacing: 12) {
          HStack {
            Text(snapshot.strings.analysisConfiguration)
              .font(.headline)
            Spacer()
            Button {
              expanded = false
            } label: {
              Label(snapshot.strings.close, systemImage: "xmark")
            }
            .buttonStyle(.plain)
          }
          RepoLensMacAnalysisProviderPanel(
            shellState: shellState,
            showAnalyzeButton: true,
            wrappedPanel: false,
            showTitle: false
          )
        }
      }
    } else {
      RepoLensNativeActionButton(
        title: snapshot.strings.analysisConfiguration,
        systemImage: "slider.horizontal.3",
        prominent: true
      ) {
        expanded = true
      }
    }
  }
}

struct RepoLensMacAnalysisPage: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  @Environment(\.repoLensTokens) private var tokens

  var body: some View {
    let snapshot = shellState.snapshot
    VStack(alignment: .leading, spacing: 16) {
      RepoLensPageHeader(
        title: snapshot.strings.analysis,
        subtitle: snapshot.strings.analysisSubtitle,
        action: RepoLensNativeActionButton(
          title: snapshot.strings.history,
          systemImage: "clock.arrow.circlepath"
        ) {
          shellState.select(3)
        }
      )
      RepoLensNativeGlassPanel {
        if let analysis = snapshot.selectedAnalysis {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text(analysis.category)
                .font(.headline)
              Spacer()
              Text(String(format: "%.0f", analysis.score))
                .font(.title2.weight(.semibold))
                .foregroundColor(tokens.accent)
            }
            Text(analysis.summary)
              .foregroundColor(.secondary)
            if !analysis.businessFit.isEmpty {
              RepoLensDetailLine(label: snapshot.strings.businessFit, value: analysis.businessFit)
            }
            if !analysis.recommendation.isEmpty {
              RepoLensDetailLine(label: snapshot.strings.recommendation, value: analysis.recommendation)
            }
            RepoLensTextSection(title: snapshot.strings.nextSteps, values: analysis.nextSteps)
            RepoLensTextSection(title: snapshot.strings.useCases, values: analysis.useCases)
            RepoLensTextSection(title: snapshot.strings.techStack, values: analysis.techStack)
            RepoLensTextSection(
              title: snapshot.strings.analysisDimensions,
              values: analysis.dimensions.map { "\($0.title) \(String(format: "%.0f", $0.score)): \($0.summary)" }
            )
            RepoLensTextSection(title: snapshot.strings.architectureNotes, values: analysis.architectureNotes)
            RepoLensTextSection(title: snapshot.strings.qualitySignals, values: analysis.qualitySignals)
            RepoLensTextSection(title: snapshot.strings.securityNotes, values: analysis.securityNotes)
            RepoLensTextSection(title: snapshot.strings.risks, values: analysis.risks)
          }
        } else {
          Text(snapshot.strings.noAnalysis)
            .foregroundColor(.secondary)
        }
      }
      RepoLensMacAnalysisExportPanel(shellState: shellState)
    }
  }
}

struct RepoLensMacAnalysisProviderPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  var showAnalyzeButton = false
  var wrappedPanel = true
  var showTitle = true

  var body: some View {
    if wrappedPanel {
      RepoLensNativeGlassPanel {
        panelContent
      }
    } else {
      panelContent
    }
  }

  @ViewBuilder
  private var panelContent: some View {
    let snapshot = shellState.snapshot
    let settings = snapshot.settings
    let models = analysisModels(settings)
    VStack(alignment: .leading, spacing: 12) {
      if showTitle {
        Text(snapshot.strings.analysisConfiguration)
          .font(.headline)
      }
      Picker(snapshot.strings.providerName, selection: Binding(
        get: { settings.selectedProviderId },
        set: { shellState.selectProvider($0) }
      )) {
        ForEach(settings.providers) { provider in
          Text(provider.name).tag(provider.id)
        }
      }
      Picker(snapshot.strings.defaultModel, selection: Binding(
        get: { settings.defaultModel },
        set: { modelId in
          guard let selectedModel = models.first(where: { $0.id == modelId }) ?? models.first else {
            return
          }
          var payload = settings.providerRaw
          payload["defaultModel"] = selectedModel.id
          payload["contextLength"] = selectedModel.contextLength
          payload["supportsStructuredOutput"] = selectedModel.supportsStructuredOutput
          payload["supportsToolCalling"] = selectedModel.supportsToolCalling
          payload["availableModels"] = models.map { $0.toMap() }
          shellState.saveProvider(payload)
        }
      )) {
        ForEach(models) { model in
          Text(model.displayName).tag(model.id)
        }
      }
      RepoLensNativeActionButton(
        title: snapshot.isFetchingModels ? snapshot.strings.loading : snapshot.strings.fetchProviderModels,
        systemImage: "arrow.down.circle"
      ) {
        shellState.refreshSelectedProviderModels()
      }
      if showAnalyzeButton {
        RepoLensNativeActionButton(
          title: snapshot.isAnalyzing ? snapshot.strings.loading : snapshot.strings.analyzeThisProject,
          systemImage: "sparkles",
          prominent: true
        ) {
          shellState.analyzeSelectedProjectAndOpenAnalysis()
        }
      }
    }
  }

  private func analysisModels(_ settings: RepoLensNativeSettings) -> [RepoLensNativeModel] {
    if settings.availableModels.contains(where: { $0.id == settings.defaultModel }) {
      return settings.availableModels
    }
    return [
      RepoLensNativeModel(map: [
        "id": settings.defaultModel,
        "displayName": settings.defaultModel,
        "contextLength": settings.contextLength,
        "supportsStructuredOutput": settings.supportsStructuredOutput,
        "supportsToolCalling": settings.supportsToolCalling,
      ]),
    ] + settings.availableModels
  }
}

struct RepoLensMacAnalysisExportPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 10) {
        Text(snapshot.strings.exportThisAnalysis)
          .font(.headline)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
          ForEach(["json", "markdown", "pdf", "png"], id: \.self) { format in
            RepoLensNativeActionButton(title: snapshot.strings.exportLabel(format), systemImage: "square.and.arrow.up") {
              shellState.exportSelected(format)
            }
          }
        }
      }
    }
  }
}

struct RepoLensMacExportsPage: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    VStack(alignment: .leading, spacing: 16) {
      RepoLensPageHeader(title: snapshot.strings.exports, subtitle: snapshot.strings.exportsSubtitle)
      RepoLensNativeGlassPanel {
        VStack(alignment: .leading, spacing: 10) {
          Text(snapshot.strings.exportHistory)
            .font(.headline)
          if snapshot.exports.isEmpty {
            Text(snapshot.strings.emptyExports)
              .foregroundColor(.secondary)
          } else {
            ForEach(snapshot.exports) { bundle in
              HStack(alignment: .center, spacing: 10) {
                RepoLensDetailLine(
                  label: snapshot.strings.exportLabel(bundle.format),
                  value: "\(bundle.projectCount) · \(bundle.filePath)"
                )
                RepoLensNativeActionButton(
                  title: snapshot.strings.openExportFile,
                  systemImage: "doc.viewfinder"
                ) {
                  shellState.openExportFile(bundle.filePath)
                }
                RepoLensNativeActionButton(
                  title: snapshot.strings.deleteExport,
                  systemImage: "trash"
                ) {
                  shellState.deleteExport(id: bundle.id)
                }
              }
              Divider()
            }
          }
        }
      }
    }
  }
}

struct RepoLensMacSettingsPage: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    VStack(alignment: .leading, spacing: 16) {
      if snapshot.settingsProviderDetailOpen {
        RepoLensPageHeader(
          title: snapshot.strings.aiProviders,
          subtitle: snapshot.strings.providerSettingsDetailSubtitle,
          action: RepoLensNativeActionButton(
            title: snapshot.strings.settings,
            systemImage: "chevron.left"
          ) {
            shellState.closeSettingsProviderDetail()
          }
        )
        RepoLensMacProviderPanel(shellState: shellState)
          .id(snapshot.settings.selectedProviderId)
      } else if snapshot.settingsAppearanceDetailOpen {
        RepoLensPageHeader(
          title: snapshot.strings.appearanceSettings,
          subtitle: snapshot.strings.appearanceSettingsSubtitle,
          action: RepoLensNativeActionButton(
            title: snapshot.strings.settings,
            systemImage: "chevron.left"
          ) {
            shellState.closeSettingsAppearanceDetail()
          }
        )
        RepoLensMacAppearancePanel(shellState: shellState)
      } else {
        RepoLensPageHeader(title: snapshot.strings.settings, subtitle: snapshot.strings.settingsSubtitle)
        RepoLensMacLanguagePanel(shellState: shellState)
        RepoLensMacAppearanceEntryPanel(shellState: shellState)
        RepoLensMacProviderEntryPanel(shellState: shellState)
        RepoLensMacCredentialPanel(shellState: shellState)
        RepoLensNativeGlassPanel {
          Toggle(
            snapshot.strings.mcpWriteAccess,
            isOn: Binding(
              get: { snapshot.settings.mcpWriteAccessEnabled },
              set: { shellState.updateMcpWriteAccess($0) }
            )
          )
        }
      }
    }
  }
}

struct RepoLensMacAppearanceEntryPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Text(snapshot.strings.appearanceSettings)
          .font(.headline)
        Text(snapshot.strings.appearanceSummary)
          .font(.caption)
          .foregroundColor(.secondary)
        HStack {
          RepoLensNativeChip(text: "Apple Liquid Glass", systemImage: "sparkles")
          RepoLensNativeChip(text: snapshot.settings.themeColor, systemImage: "paintpalette")
          Spacer()
          RepoLensNativeActionButton(
            title: snapshot.strings.configureAppearance,
            systemImage: "chevron.right"
          ) {
            shellState.openSettingsAppearanceDetail()
          }
        }
      }
    }
  }
}

struct RepoLensMacAppearancePanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    RepoLensNativeGlassPanel {
      RepoLensNativeColorPalette(
        title: snapshot.strings.themeColor,
        hint: snapshot.strings.themeColorHint,
        value: snapshot.settings.themeColor,
        options: RepoLensNativeColorOption.themeDefaults,
        onSelect: shellState.updateThemeColor
      )
    }
  }
}

struct RepoLensMacLanguagePanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Picker(
          snapshot.strings.displayLanguage,
          selection: Binding(
            get: { snapshot.settings.language },
            set: { shellState.updateLanguage($0) }
          )
        ) {
          Text(snapshot.strings.systemLanguage).tag("system")
          Text("简体中文").tag("simplifiedChinese")
          Text("English").tag("english")
        }
        Picker(
          snapshot.strings.themeMode,
          selection: Binding(
            get: { snapshot.settings.themeMode },
            set: { shellState.updateThemeMode($0) }
          )
        ) {
          Text(snapshot.strings.systemLanguage).tag("system")
          Text(snapshot.strings.themeLight).tag("light")
          Text(snapshot.strings.themeDark).tag("dark")
        }
      }
    }
  }
}

struct RepoLensMacProviderEntryPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let snapshot = shellState.snapshot
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Text(snapshot.strings.aiProviders)
          .font(.headline)
        Text(snapshot.strings.tokenMixProviderHint)
          .font(.caption)
          .foregroundColor(.secondary)
        HStack {
          RepoLensNativeChip(text: snapshot.settings.providerName, systemImage: "network")
          RepoLensNativeChip(text: snapshot.settings.defaultModel, systemImage: "memorychip")
          Spacer()
          RepoLensNativeActionButton(
            title: snapshot.strings.configureProviders,
            systemImage: "chevron.right"
          ) {
            shellState.openSettingsProviderDetail()
          }
        }
      }
    }
  }
}

struct RepoLensMacProviderPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  @State private var providerName = ""
  @State private var baseUrl = ""
  @State private var providerKey = ""
  @State private var model = ""
  @State private var contextLength = ""
  @State private var temperature = ""
  @State private var maxTokens = ""
  @State private var providerProtocol = "openAiChatCompletions"
  @State private var structuredOutput = true
  @State private var toolCalling = true

  var body: some View {
    let snapshot = shellState.snapshot
    let models = providerModels(snapshot.settings)
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Text(snapshot.strings.aiProviders)
          .font(.headline)
        Text(snapshot.strings.tokenMixProviderHint)
          .font(.caption)
          .foregroundColor(.secondary)
        if !snapshot.settings.providers.isEmpty {
          Picker(snapshot.strings.providerName, selection: Binding(
            get: { snapshot.settings.selectedProviderId },
            set: { shellState.selectProvider($0) }
          )) {
            ForEach(snapshot.settings.providers) { provider in
              Text("\(provider.name) · \(provider.defaultModel)").tag(provider.id)
            }
          }
        }
        Picker("Protocol", selection: $providerProtocol) {
          Text("OpenAI").tag("openAiChatCompletions")
          Text("Anthropic").tag("anthropicMessages")
        }
        .pickerStyle(.segmented)
        TextField(snapshot.strings.providerName, text: $providerName)
        TextField("Base URL", text: $baseUrl)
        RepoLensRevealableSecureField(
          title: snapshot.strings.selectedProviderApiKey,
          showTitle: snapshot.strings.showSecret,
          hideTitle: snapshot.strings.hideSecret,
          text: $providerKey
        )
        if snapshot.settings.availableModels.isEmpty {
          TextField(snapshot.strings.defaultModel, text: $model)
        } else {
          Picker(snapshot.strings.defaultModel, selection: Binding(
            get: { model },
            set: { modelId in
              guard let selectedModel = models.first(where: { $0.id == modelId }) ?? models.first else {
                return
              }
              model = selectedModel.id
              contextLength = "\(selectedModel.contextLength)"
              structuredOutput = selectedModel.supportsStructuredOutput
              toolCalling = selectedModel.supportsToolCalling
            }
          )) {
            ForEach(models) { model in
              Text(model.displayName).tag(model.id)
            }
          }
        }
        TextField(snapshot.strings.contextLength, text: $contextLength)
        TextField("temperature", text: $temperature)
        TextField("max output tokens", text: $maxTokens)
        Toggle(snapshot.strings.structuredOutput, isOn: $structuredOutput)
        Toggle(snapshot.strings.toolCalling, isOn: $toolCalling)
        RepoLensNativeActionButton(title: snapshot.strings.saveProvider, systemImage: "checkmark.circle", prominent: true) {
          let selectedContextLength = Int(contextLength) ?? snapshot.settings.contextLength
          let availableModels = providerModelsForSave(
            settings: snapshot.settings,
            model: model,
            contextLength: selectedContextLength
          )
          var payload = snapshot.settings.providerRaw
          payload["name"] = providerName
          payload["protocol"] = providerProtocol
          payload["baseUrl"] = baseUrl
          payload["defaultModel"] = model
          payload["contextLength"] = selectedContextLength
          payload["temperature"] = Double(temperature) ?? snapshot.settings.temperature
          payload["maxOutputTokens"] = Int(maxTokens) ?? snapshot.settings.maxOutputTokens
          payload["supportsStructuredOutput"] = structuredOutput
          payload["supportsToolCalling"] = toolCalling
          payload["availableModels"] = availableModels.map { $0.toMap() }
          shellState.saveProvider(payload)
          if !providerKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            shellState.saveProviderApiKey(
              providerKey.trimmingCharacters(in: .whitespacesAndNewlines),
              apiKeyRef: payload["apiKeyRef"] as? String ?? payload["id"] as? String
            )
          }
        }
        HStack {
          RepoLensNativeActionButton(title: snapshot.strings.addProvider, systemImage: "plus") {
            shellState.addProvider(Self.newProviderPayload())
          }
          RepoLensNativeActionButton(
            title: snapshot.isFetchingModels ? snapshot.strings.loading : snapshot.strings.fetchProviderModels,
            systemImage: "arrow.down.circle"
          ) {
            shellState.refreshSelectedProviderModels()
          }
          if snapshot.settings.providers.count > 1 {
            RepoLensNativeActionButton(title: snapshot.strings.deleteProvider, systemImage: "trash") {
              shellState.deleteProvider(snapshot.settings.selectedProviderId)
            }
          }
        }
      }
    }
    .onAppear {
      let settings = shellState.snapshot.settings
      syncFields(settings)
      loadProviderApiKey(for: settings.selectedProviderId)
    }
    .onChange(of: shellState.snapshot.settings.selectedProviderId) { _ in
      let settings = shellState.snapshot.settings
      syncFields(settings)
      loadProviderApiKey(for: settings.selectedProviderId)
    }
  }

  private func syncFields(_ settings: RepoLensNativeSettings) {
    providerName = settings.providerName
    baseUrl = settings.baseUrl
    model = settings.defaultModel
    contextLength = "\(settings.contextLength)"
    temperature = "\(settings.temperature)"
    maxTokens = "\(settings.maxOutputTokens)"
    providerProtocol = settings.providerProtocol
    structuredOutput = settings.supportsStructuredOutput
    toolCalling = settings.supportsToolCalling
  }

  private func loadProviderApiKey(for providerId: String) {
    providerKey = ""
    shellState.readSelectedProviderApiKey { apiKey in
      if shellState.snapshot.settings.selectedProviderId == providerId {
        providerKey = apiKey
      }
    }
  }

  private func providerModels(_ settings: RepoLensNativeSettings) -> [RepoLensNativeModel] {
    if settings.availableModels.contains(where: { $0.id == settings.defaultModel }) {
      return settings.availableModels
    }
    return [
      RepoLensNativeModel(map: [
        "id": settings.defaultModel,
        "displayName": settings.defaultModel,
        "contextLength": settings.contextLength,
        "supportsStructuredOutput": settings.supportsStructuredOutput,
        "supportsToolCalling": settings.supportsToolCalling,
      ]),
    ] + settings.availableModels
  }

  private static func newProviderPayload() -> [String: Any] {
    let id = "openai-compatible-\(Int(Date().timeIntervalSince1970 * 1000))"
    return [
      "id": id,
      "name": "OpenAI-compatible",
      "type": "openAiCompatible",
      "protocol": "openAiChatCompletions",
      "baseUrl": "https://api.openai.com/v1",
      "apiKeyRef": id,
      "defaultModel": "gpt-4.1-mini",
      "contextLength": 128000,
      "temperature": 0.2,
      "maxOutputTokens": 2200,
      "supportsStructuredOutput": true,
      "supportsToolCalling": true,
      "availableModels": [[
        "id": "gpt-4.1-mini",
        "displayName": "gpt-4.1-mini",
        "contextLength": 128000,
        "supportsStructuredOutput": true,
        "supportsToolCalling": true,
      ]],
    ]
  }

  private func providerModelsForSave(
    settings: RepoLensNativeSettings,
    model: String,
    contextLength: Int
  ) -> [RepoLensNativeModel] {
    if settings.availableModels.contains(where: { $0.id == model }) {
      return settings.availableModels
    }
    return [
      RepoLensNativeModel(map: [
        "id": model,
        "displayName": model,
        "contextLength": contextLength,
        "supportsStructuredOutput": structuredOutput,
        "supportsToolCalling": toolCalling,
      ]),
    ] + settings.availableModels
  }
}

struct RepoLensMacCredentialPanel: View {
  @ObservedObject var shellState: RepoLensNativeShellState
  @State private var githubToken = ""

  var body: some View {
    let strings = shellState.snapshot.strings
    RepoLensNativeGlassPanel {
      VStack(alignment: .leading, spacing: 12) {
        Text("GitHub Token")
          .font(.headline)
        Text(strings.githubTokenHint)
          .font(.caption)
          .foregroundColor(.secondary)
        RepoLensRevealableSecureField(
          title: "GitHub Token",
          showTitle: strings.showSecret,
          hideTitle: strings.hideSecret,
          text: $githubToken
        )
        HStack {
          RepoLensNativeActionButton(title: strings.saveGithubToken, systemImage: "key") {
            shellState.saveGithubToken(githubToken)
            githubToken = ""
          }
        }
      }
    }
  }
}

struct RepoLensDetailLine: View {
  let label: String
  let value: String

  var body: some View {
    HStack(alignment: .top) {
      Text(label)
        .font(.caption.weight(.semibold))
        .foregroundColor(.secondary)
        .frame(width: 92, alignment: .leading)
      Text(value)
        .font(.footnote)
        .textSelection(.enabled)
      Spacer()
    }
  }
}

struct RepoLensTextSection: View {
  let title: String
  let values: [String]

  var body: some View {
    if !values.isEmpty {
      VStack(alignment: .leading, spacing: 6) {
        Text(title)
          .font(.subheadline.weight(.semibold))
        ForEach(values, id: \.self) { value in
          Text("• \(value)")
            .font(.footnote)
            .foregroundColor(.secondary)
        }
      }
    }
  }
}
