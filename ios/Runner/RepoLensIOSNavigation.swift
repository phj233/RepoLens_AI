import Flutter
import SwiftUI
import UIKit

struct RepoLensNativeNavItem: Identifiable {
  let index: Int
  let title: String
  let shortTitle: String
  let systemImage: String

  var id: Int { index }

  static let items: [RepoLensNativeNavItem] = {
    let zh = Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") ?? false
    return [
      RepoLensNativeNavItem(
        index: 0,
        title: zh ? "发现" : "Discovery",
        shortTitle: zh ? "发现" : "Discover",
        systemImage: "scope"
      ),
      RepoLensNativeNavItem(
        index: 1,
        title: zh ? "项目" : "Projects",
        shortTitle: zh ? "项目" : "Projects",
        systemImage: "folder"
      ),
      RepoLensNativeNavItem(
        index: 2,
        title: zh ? "分析" : "Analysis",
        shortTitle: zh ? "分析" : "Analysis",
        systemImage: "sparkles"
      ),
      RepoLensNativeNavItem(
        index: 3,
        title: zh ? "导出" : "Exports",
        shortTitle: zh ? "导出" : "Exports",
        systemImage: "square.and.arrow.up"
      ),
      RepoLensNativeNavItem(
        index: 4,
        title: zh ? "设置" : "Settings",
        shortTitle: zh ? "设置" : "Settings",
        systemImage: "slider.horizontal.3"
      ),
    ]
  }()
}

extension RepoLensNativeShellState {
  var selectedItem: RepoLensNativeNavItem {
    RepoLensNativeNavItem.items.first { $0.index == selectedIndex }
      ?? RepoLensNativeNavItem.items[0]
  }
}

extension Int {
  var compactString: String {
    if self >= 1_000_000 {
      return String(format: "%.1fM", Double(self) / 1_000_000)
    }
    if self >= 1_000 {
      return String(format: "%.1fK", Double(self) / 1_000)
    }
    return "\(self)"
  }
}
