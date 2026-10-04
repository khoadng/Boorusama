import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var appPrivacyChannel: AppPrivacyChannel?
  private var webViewCookieChannel: WebViewCookieChannel?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    appPrivacyChannel = AppPrivacyChannel(
      window: self,
      messenger: flutterViewController.engine.binaryMessenger
    )
    appPrivacyChannel?.register()
    webViewCookieChannel = WebViewCookieChannel(
      messenger: flutterViewController.engine.binaryMessenger
    )
    webViewCookieChannel?.register()

    super.awakeFromNib()
  }
}
