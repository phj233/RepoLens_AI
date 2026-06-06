import Cocoa
import FlutterMacOS
import SwiftUI

final class RepoLensNativeShellState: ObservableObject {
  @Published var selectedIndex = 0
  @Published var snapshot = RepoLensNativeSnapshot.empty

  private let channel: FlutterMethodChannel

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "stateChanged":
        self?.applySnapshot(call.arguments)
        result(nil)
      case "navigationIndexChanged":
        let index = call.arguments as? Int ?? 0
        DispatchQueue.main.async {
          self?.selectedIndex = index
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func select(_ index: Int) {
    selectedIndex = index
    invoke("setNavigationIndex", arguments: index)
  }

  func refresh() {
    channel.invokeMethod("requestState", arguments: nil) { [weak self] result in
      self?.applySnapshot(result)
    }
  }

  func updateFilters(keyword: String, dateRange: String, language: String, minStars: Int) {
    invoke(
      "updateFilters",
      arguments: [
        "keyword": keyword,
        "dateRange": dateRange,
        "language": language,
        "minStars": minStars,
      ]
    )
  }

  func discover() {
    invoke("discover")
  }

  func selectProject(_ fullName: String) {
    invoke("selectProject", arguments: fullName)
  }

  func openProjectDetail(_ fullName: String) {
    invoke("openProjectDetail", arguments: fullName)
  }

  func closeProjectDetail() {
    invoke("closeProjectDetail")
  }

  func openSettingsProviderDetail() {
    invoke("openSettingsProviderDetail")
  }

  func closeSettingsProviderDetail() {
    invoke("closeSettingsProviderDetail")
  }

  func openSettingsAppearanceDetail() {
    invoke("openSettingsAppearanceDetail")
  }

  func closeSettingsAppearanceDetail() {
    invoke("closeSettingsAppearanceDetail")
  }

  func dismissMessage() {
    invoke("dismissMessage")
  }

  func closeImagePreview() {
    invoke("closeImagePreview")
  }

  func toggleFavorite(_ fullName: String) {
    invoke("toggleFavorite", arguments: fullName)
  }

  func analyzeSelectedProject() {
    invoke("analyzeSelectedProject")
  }

  func analyzeSelectedProjectAndOpenAnalysis() {
    invoke("analyzeSelectedProjectAndOpenAnalysis")
  }

  func export(_ format: String) {
    invoke("exportCurrentData", arguments: format)
  }

  func exportSelected(_ format: String) {
    invoke("exportSelectedProjectData", arguments: format)
  }

  func openExportFile(_ filePath: String) {
    invoke("openExportFile", arguments: filePath)
  }

  func deleteExport(id: String) {
    invoke("deleteExport", arguments: ["id": id])
  }

  func updateLanguage(_ language: String) {
    invoke("updateLanguage", arguments: language)
  }

  func updateThemeMode(_ mode: String) {
    invoke("updateThemeMode", arguments: mode)
  }

  func updateThemeColor(_ color: String) {
    invoke("updateThemeColor", arguments: color)
  }

  func updateMcpWriteAccess(_ enabled: Bool) {
    invoke("updateMcpWriteAccess", arguments: enabled)
  }

  func addProvider(_ provider: [String: Any]) {
    invoke("addProvider", arguments: provider)
  }

  func selectProvider(_ providerId: String) {
    invoke("selectProvider", arguments: providerId)
  }

  func deleteProvider(_ providerId: String) {
    invoke("deleteProvider", arguments: providerId)
  }

  func refreshSelectedProviderModels() {
    invoke("refreshSelectedProviderModels")
  }

  func saveProvider(_ provider: [String: Any]) {
    invoke("updateProvider", arguments: provider)
  }

  func saveGithubToken(_ token: String) {
    invoke("saveGithubToken", arguments: token)
  }

  func saveProviderApiKey(_ apiKey: String, apiKeyRef: String? = nil) {
    var arguments: [String: Any] = ["apiKey": apiKey]
    if let apiKeyRef {
      arguments["apiKeyRef"] = apiKeyRef
    }
    invoke("saveProviderApiKey", arguments: arguments)
  }

  func readSelectedProviderApiKey(_ completion: @escaping (String) -> Void) {
    channel.invokeMethod("readSelectedProviderApiKey", arguments: nil) { result in
      DispatchQueue.main.async {
        completion(result as? String ?? "")
      }
    }
  }

  private func invoke(_ method: String, arguments: Any? = nil) {
    channel.invokeMethod(method, arguments: arguments) { [weak self] _ in
      self?.refresh()
    }
  }

  private func applySnapshot(_ value: Any?) {
    guard let map = value as? [String: Any] else {
      return
    }
    DispatchQueue.main.async {
      let snapshot = RepoLensNativeSnapshot(map: map)
      self.snapshot = snapshot
      self.selectedIndex = snapshot.navigationIndex
    }
  }
}
