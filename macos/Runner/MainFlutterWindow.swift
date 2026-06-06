import Cocoa
import FlutterMacOS
import SwiftUI

class MainFlutterWindow: NSWindow {
  private var flutterViewController: FlutterViewController?
  private var shellState: RepoLensNativeShellState?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame

    RegisterGeneratedPlugins(registry: flutterViewController)
    flutterViewController
      .registrar(forPlugin: "RepoLensNativeLiquidGlass")
      .register(
        AppleNativeLiquidGlassSurfaceFactory(),
        withId: "repolens.ai/native_liquid_glass_surface"
      )

    let channel = FlutterMethodChannel(
      name: "repolens.ai/native_shell",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    let fileOpenerChannel = FlutterMethodChannel(
      name: "repolens.ai/file_opener",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    fileOpenerChannel.setMethodCallHandler { call, result in
      guard call.method == "openFile" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let path = arguments["path"] as? String,
        !path.isEmpty
      else {
        result(FlutterError(code: "missing_path", message: "File path is required.", details: nil))
        return
      }

      let url = URL(fileURLWithPath: path)
      guard FileManager.default.fileExists(atPath: url.path) else {
        result(FlutterError(code: "missing_file", message: "File does not exist.", details: path))
        return
      }

      if NSWorkspace.shared.open(url) {
        result(nil)
      } else {
        result(FlutterError(code: "open_failed", message: "Could not open file.", details: path))
      }
    }
    let shellState = RepoLensNativeShellState(channel: channel)
    self.contentViewController = NSHostingController(
      rootView: RepoLensMacNativeShell(
        flutterViewController: flutterViewController,
        shellState: shellState
      )
    )
    self.setFrame(windowFrame, display: true)
    self.title = "RepoLens AI"
    if #available(macOS 11.0, *) {
      self.toolbarStyle = .unified
    }

    self.flutterViewController = flutterViewController
    self.shellState = shellState

    super.awakeFromNib()
  }
}
