import Cocoa
import FlutterMacOS
import SwiftUI

struct RepoLensMacNativeShell: View {
  let flutterViewController: FlutterViewController

  @ObservedObject var shellState: RepoLensNativeShellState

  var body: some View {
    let tokens = RepoLensNativeTokens(settings: shellState.snapshot.settings)
    Group {
      if #available(macOS 13.0, *) {
        NavigationSplitView {
          nativeSidebar
            .navigationSplitViewColumnWidth(min: 220, ideal: 248, max: 280)
        } detail: {
          shellDetail
            .toolbar {
              ToolbarItem(placement: .principal) {
                Text(shellState.selectedItem.title)
                  .font(.headline)
              }
            }
        }
      } else {
        HStack(spacing: 0) {
          nativeSidebar
            .frame(width: 248)
          Divider()
          shellDetail
        }
      }
    }
    .preferredColorScheme(nativeColorScheme)
    .tint(tokens.accent)
    .environment(\.repoLensTokens, tokens)
  }

  private var nativeColorScheme: ColorScheme? {
    switch shellState.snapshot.settings.themeMode {
    case "light":
      return .light
    case "dark":
      return .dark
    default:
      return nil
    }
  }

  private var nativeSidebar: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack(alignment: .leading, spacing: 4) {
        Text("RepoLens AI")
          .font(.system(size: 16, weight: .semibold))
        Text(nativeSubtitle)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal, 16)
      .padding(.top, 18)
      .padding(.bottom, 14)

      ForEach(RepoLensNativeNavItem.items) { item in
        RepoLensMacSidebarButton(
          item: item,
          isSelected: shellState.selectedIndex == item.index,
          icon: { nativeIcon(for: item) }
        ) {
          shellState.select(item.index)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
      }

      Spacer()
      Text("Liquid Glass")
        .font(.caption.weight(.semibold))
        .foregroundColor(.secondary)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .nativeMaterialBackground()
  }

  private var shellDetail: some View {
    ZStack(alignment: .topTrailing) {
      Color(NSColor.windowBackgroundColor).ignoresSafeArea()
      nativeDetail
      HiddenFlutterMacContentView(controller: flutterViewController)
        .frame(width: 1, height: 1)
        .opacity(0.01)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
      if let message = shellState.snapshot.message {
        RepoLensMacToast(
          message: message,
          isError: shellState.snapshot.errorMessage != nil,
          onClose: shellState.dismissMessage
        )
        .padding(16)
      }
      if shellState.selectedIndex == 1,
         shellState.snapshot.projectDetailOpen,
         shellState.snapshot.selectedProject != nil {
        VStack {
          Spacer()
          HStack {
            Spacer()
            RepoLensMacFloatingAnalysisConfig(shellState: shellState)
              .frame(maxWidth: 520)
          }
          .padding(24)
        }
      }
      if let previewPath = shellState.snapshot.previewImagePath {
        RepoLensMacImagePreviewOverlay(
          path: previewPath,
          strings: shellState.snapshot.strings,
          onClose: shellState.closeImagePreview
        )
      }
    }
    .onAppear {
      shellState.refresh()
    }
  }

  @ViewBuilder
  private var nativeDetail: some View {
    if shellState.snapshot.isBootstrapping {
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          switch shellState.selectedIndex {
          case 0:
            RepoLensMacDashboardPage(shellState: shellState)
          case 1:
            RepoLensMacProjectsPage(shellState: shellState)
          case 2:
            RepoLensMacAnalysisPage(shellState: shellState)
          case 3:
            RepoLensMacExportsPage(shellState: shellState)
          default:
            RepoLensMacSettingsPage(shellState: shellState)
          }
        }
        .padding(24)
        .frame(maxWidth: 1120, alignment: .leading)
      }
    }
  }

  @ViewBuilder
  private func nativeIcon(for item: RepoLensNativeNavItem) -> some View {
    if #available(macOS 11.0, *) {
      Image(systemName: item.systemImage)
        .font(.system(size: 15, weight: .semibold))
        .frame(width: 20)
    } else {
      Text(item.fallbackSymbol)
        .font(.system(size: 14, weight: .semibold))
        .frame(width: 20)
    }
  }

  private var nativeSubtitle: String {
    Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") == true
      ? "本地优先的 AI 项目雷达"
      : "Local-first AI project radar"
  }
}
