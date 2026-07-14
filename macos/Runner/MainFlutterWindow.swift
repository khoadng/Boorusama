import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var appPrivacyChannel: AppPrivacyChannel?

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

    super.awakeFromNib()
  }
}
