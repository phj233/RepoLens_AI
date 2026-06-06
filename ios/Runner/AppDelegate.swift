import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

final class AppleNativeLiquidGlassSurfaceFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    AppleNativeLiquidGlassSurface(frame: frame, args: args)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

private final class AppleNativeLiquidGlassSurface: NSObject, FlutterPlatformView {
  private let platformView: UIView

  init(frame: CGRect, args: Any?) {
    let params = args as? [String: Any] ?? [:]
    let cornerRadius = CGFloat((params["cornerRadius"] as? NSNumber)?.doubleValue ?? 8)
    let tintColor = UIColor(argb: (params["tintColor"] as? NSNumber)?.uint32Value ?? 0x332F7D5F)

    if #available(iOS 26.0, *),
       let glassEffectType = NSClassFromString("UIGlassEffect") as? UIVisualEffect.Type {
      let effectView = UIVisualEffectView(effect: glassEffectType.init())
      effectView.frame = frame
      effectView.isUserInteractionEnabled = false
      effectView.backgroundColor = tintColor
      effectView.clipsToBounds = true
      effectView.layer.cornerRadius = cornerRadius
      platformView = effectView
    } else {
      let blur = UIBlurEffect(style: .systemUltraThinMaterial)
      let effectView = UIVisualEffectView(effect: blur)
      effectView.frame = frame
      effectView.isUserInteractionEnabled = false
      effectView.backgroundColor = tintColor
      effectView.clipsToBounds = true
      effectView.layer.cornerRadius = cornerRadius
      platformView = effectView
    }

    super.init()
  }

  func view() -> UIView {
    platformView
  }
}

private extension UIColor {
  convenience init(argb: UInt32) {
    let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
    let red = CGFloat((argb >> 16) & 0xFF) / 255.0
    let green = CGFloat((argb >> 8) & 0xFF) / 255.0
    let blue = CGFloat(argb & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
