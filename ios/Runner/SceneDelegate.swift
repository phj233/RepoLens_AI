import Flutter
import QuickLook
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, QLPreviewControllerDataSource {
  var window: UIWindow?

  private var flutterViewController: FlutterViewController?
  private var shellState: RepoLensNativeShellState?
  private var previewURL: URL?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let flutterViewController = FlutterViewController(
      project: nil,
      nibName: nil,
      bundle: nil
    )
    GeneratedPluginRegistrant.register(with: flutterViewController)
    if let registrar = flutterViewController.registrar(
      forPlugin: "RepoLensNativeLiquidGlass"
    ) {
      registrar.register(
        AppleNativeLiquidGlassSurfaceFactory(),
        withId: "repolens.ai/native_liquid_glass_surface"
      )
    }

    let channel = FlutterMethodChannel(
      name: "repolens.ai/native_shell",
      binaryMessenger: flutterViewController.binaryMessenger
    )
    configureFileOpener(binaryMessenger: flutterViewController.binaryMessenger)
    let shellState = RepoLensNativeShellState(channel: channel)
    let hostingController = UIHostingController(
      rootView: RepoLensIOSNativeShell(
        flutterViewController: flutterViewController,
        shellState: shellState
      )
    )

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    self.window = window
    self.flutterViewController = flutterViewController
    self.shellState = shellState
  }

  private func configureFileOpener(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "repolens.ai/file_opener",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
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
      self?.presentPreview(path: path, result: result)
    }
  }

  private func presentPreview(path: String, result: @escaping FlutterResult) {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else {
      result(FlutterError(code: "missing_file", message: "File does not exist.", details: path))
      return
    }
    guard let rootViewController = window?.rootViewController else {
      result(FlutterError(code: "no_view_controller", message: "No presenter is available.", details: nil))
      return
    }

    previewURL = url
    let previewController = QLPreviewController()
    previewController.dataSource = self
    topViewController(from: rootViewController).present(previewController, animated: true)
    result(nil)
  }

  private func topViewController(from controller: UIViewController) -> UIViewController {
    if let presented = controller.presentedViewController {
      return topViewController(from: presented)
    }
    return controller
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    previewURL == nil ? 0 : 1
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    previewURL! as NSURL
  }
}
