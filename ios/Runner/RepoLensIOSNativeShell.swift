import Flutter
import SwiftUI
import UIKit

struct RepoLensIOSNativeShell: View {
  let flutterViewController: FlutterViewController

  @ObservedObject var shellState: RepoLensNativeShellState

  @ViewBuilder
  var body: some View {
    shellContent
  }

  @ViewBuilder
  private var shellContent: some View {
    let tokens = RepoLensNativeTokens(settings: shellState.snapshot.settings)
    ZStack(alignment: .topTrailing) {
      Color(UIColor.systemGroupedBackground).ignoresSafeArea()
      nativePage
      HiddenFlutterContentView(controller: flutterViewController)
        .frame(width: 1, height: 1)
        .opacity(0.01)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
      if let message = shellState.snapshot.message {
        RepoLensIOSToast(
          message: message,
          isError: shellState.snapshot.errorMessage != nil,
          onClose: shellState.dismissMessage
        )
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .zIndex(20)
      }
      if #available(iOS 26.0, *) {
        VStack {
          Spacer()
          liquidGlassBottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      if shellState.selectedIndex == 1,
         shellState.snapshot.projectDetailOpen,
         shellState.snapshot.selectedProject != nil {
        VStack {
          Spacer()
          HStack {
            Spacer()
            RepoLensIOSFloatingAnalysisConfig(shellState: shellState)
              .frame(maxWidth: 520)
          }
          .padding(.horizontal, 16)
          .padding(.bottom, floatingAnalysisBottomPadding)
        }
      }
      if let previewPath = shellState.snapshot.previewImagePath {
        RepoLensIOSImagePreviewOverlay(
          path: previewPath,
          strings: shellState.snapshot.strings,
          onClose: shellState.closeImagePreview
        )
      }
    }
    .onAppear {
      shellState.refresh()
    }
    .refreshableIfAvailable {
      shellState.refresh()
    }
    .safeAreaInsetIfAvailable {
      if #available(iOS 26.0, *) {
        EmptyView()
      } else {
        nativeBottomBar
      }
    } legacyContent: {
      VStack(spacing: 0) {
        nativePage
        nativeBottomBar
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

  @ViewBuilder
  private var nativePage: some View {
    if shellState.snapshot.isBootstrapping {
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          switch shellState.selectedIndex {
          case 0:
            RepoLensIOSDashboardPage(shellState: shellState)
          case 1:
            RepoLensIOSProjectsPage(shellState: shellState)
          case 2:
            RepoLensIOSAnalysisPage(shellState: shellState)
          case 3:
            RepoLensIOSExportsPage(shellState: shellState)
          default:
            RepoLensIOSSettingsPage(shellState: shellState)
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, pageBottomPadding)
      }
    }
  }

  private var pageBottomPadding: CGFloat {
    if #available(iOS 26.0, *) {
      return 118
    }
    return 28
  }

  private var floatingAnalysisBottomPadding: CGFloat {
    if #available(iOS 26.0, *) {
      return 108
    }
    return 24
  }

  @ViewBuilder
  private var nativeBottomBar: some View {
    if #available(iOS 26.0, *) {
      liquidGlassBottomBar
    } else {
      materialBottomBar
    }
  }

  @available(iOS 26.0, *)
  private var liquidGlassBottomBar: some View {
    RepoLensIOSLiquidGlassBottomBar(
      selectedIndex: shellState.selectedIndex,
      onSelect: shellState.select
    )
  }

  @ViewBuilder
  private var materialBottomBar: some View {
    let bar = VStack(spacing: 0) {
      Divider()
      HStack(spacing: 0) {
        ForEach(RepoLensNativeNavItem.items) { item in
          Button {
            shellState.select(item.index)
          } label: {
            RepoLensNativeTabLabel(
              item: item,
              isSelected: shellState.selectedIndex == item.index
            )
            .padding(.vertical, 7)
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 6)
      .padding(.bottom, 4)
    }
    if #available(iOS 15.0, *) {
      bar.background(.ultraThinMaterial)
    } else {
      bar.background(Color(UIColor.systemBackground).opacity(0.94))
    }
  }
}

private extension View {
  @ViewBuilder
  func safeAreaInsetIfAvailable(
    @ViewBuilder inset: () -> some View,
    @ViewBuilder legacyContent: () -> some View
  ) -> some View {
    if #available(iOS 15.0, *) {
      self.safeAreaInset(edge: .bottom, spacing: 0) {
        inset()
      }
    } else {
      legacyContent()
    }
  }

  @ViewBuilder
  func refreshableIfAvailable(action: @escaping () -> Void) -> some View {
    if #available(iOS 15.0, *) {
      self.refreshable {
        action()
      }
    } else {
      self
    }
  }
}

struct HiddenFlutterContentView: UIViewControllerRepresentable {
  let controller: FlutterViewController

  func makeUIViewController(context: Context) -> FlutterViewController {
    controller
  }

  func updateUIViewController(
    _ uiViewController: FlutterViewController,
    context: Context
  ) {}
}
