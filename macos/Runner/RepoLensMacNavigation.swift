import Cocoa
import FlutterMacOS
import SwiftUI

struct RepoLensNativeNavItem: Identifiable {
  let index: Int
  let title: String
  let systemImage: String
  let fallbackSymbol: String

  var id: Int { index }

  static let items: [RepoLensNativeNavItem] = {
    let zh = Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") ?? false
    return [
      RepoLensNativeNavItem(
        index: 0,
        title: zh ? "发现" : "Discovery",
        systemImage: "scope",
        fallbackSymbol: "◎"
      ),
      RepoLensNativeNavItem(
        index: 1,
        title: zh ? "项目" : "Projects",
        systemImage: "folder",
        fallbackSymbol: "▣"
      ),
      RepoLensNativeNavItem(
        index: 2,
        title: zh ? "分析" : "Analysis",
        systemImage: "sparkles",
        fallbackSymbol: "✦"
      ),
      RepoLensNativeNavItem(
        index: 3,
        title: zh ? "导出" : "Exports",
        systemImage: "square.and.arrow.up",
        fallbackSymbol: "↗"
      ),
      RepoLensNativeNavItem(
        index: 4,
        title: zh ? "设置" : "Settings",
        systemImage: "slider.horizontal.3",
        fallbackSymbol: "⌘"
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

extension View {
  @ViewBuilder
  func nativeMaterialBackground() -> some View {
    if #available(macOS 12.0, *) {
      self.background(.ultraThinMaterial)
    } else {
      self.background(Color(NSColor.windowBackgroundColor).opacity(0.94))
    }
  }
}

final class AppleNativeLiquidGlassSurfaceFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withViewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> NSView {
    let params = args as? [String: Any] ?? [:]
    let cornerRadius = CGFloat((params["cornerRadius"] as? NSNumber)?.doubleValue ?? 8)
    let tintColor = NSColor(argb: (params["tintColor"] as? NSNumber)?.uint32Value ?? 0x332F7D5F)

    if #available(macOS 26.0, *),
       let glassViewType = NSClassFromString("NSGlassEffectView") as? NSView.Type {
      let glassView = glassViewType.init(frame: .zero)
      glassView.wantsLayer = true
      glassView.layer?.cornerRadius = cornerRadius
      glassView.layer?.masksToBounds = true
      glassView.layer?.backgroundColor = tintColor.cgColor
      return glassView
    }

    let effectView = NSVisualEffectView()
    effectView.material = .hudWindow
    effectView.blendingMode = .withinWindow
    effectView.state = .active
    effectView.wantsLayer = true
    effectView.layer?.cornerRadius = cornerRadius
    effectView.layer?.masksToBounds = true
    effectView.layer?.backgroundColor = tintColor.cgColor
    return effectView
  }

  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

extension NSColor {
  convenience init(argb: UInt32) {
    let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
    let red = CGFloat((argb >> 16) & 0xFF) / 255.0
    let green = CGFloat((argb >> 8) & 0xFF) / 255.0
    let blue = CGFloat(argb & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
