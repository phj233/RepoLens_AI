import SwiftUI

struct RepoLensNativeTokens {
  static let defaultAccent = Color(red: 0.184, green: 0.490, blue: 0.373)

  let accent: Color
  let accentSoft: Color
  let onAccent: Color
  let textPrimary: Color
  let textSecondary: Color
  let danger: Color
  let warning: Color
  let info: Color
  let success: Color

  init(settings: RepoLensNativeSettings) {
    let accentColor = Color(hex: settings.themeColor) ?? Self.defaultAccent
    accent = accentColor
    accentSoft = accentColor.opacity(0.16)
    onAccent = Color(UIColor.systemBackground)
    textPrimary = .primary
    textSecondary = .secondary
    danger = .red
    warning = .yellow
    info = .blue
    success = accentColor
  }
}

private struct RepoLensNativeTokensKey: EnvironmentKey {
  static let defaultValue = RepoLensNativeTokens(settings: RepoLensNativeSettings())
}

extension EnvironmentValues {
  var repoLensTokens: RepoLensNativeTokens {
    get { self[RepoLensNativeTokensKey.self] }
    set { self[RepoLensNativeTokensKey.self] = newValue }
  }
}
