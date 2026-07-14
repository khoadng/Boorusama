import Cocoa
import FlutterMacOS

final class AppPrivacyChannel {
  private static let channelName = "app_privacy"

  private weak var window: NSWindow?
  private let channel: FlutterMethodChannel
  private var enabled = false
  private var observersRegistered = false
  private var coverView: NSView?

  init(window: NSWindow, messenger: FlutterBinaryMessenger) {
    self.window = window
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
  }

  func register() {
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setPrivacyCoverEnabled":
        let arguments = call.arguments as? [String: Any]
        let enabled = arguments?["enabled"] as? Bool ?? false
        self?.setPrivacyCoverEnabled(enabled)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setPrivacyCoverEnabled(_ enabled: Bool) {
    self.enabled = enabled

    if enabled {
      guard !observersRegistered else { return }
      observersRegistered = true

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(showPrivacyCover),
        name: NSApplication.willResignActiveNotification,
        object: nil
      )
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(hidePrivacyCover),
        name: NSApplication.didBecomeActiveNotification,
        object: nil
      )
    } else {
      guard observersRegistered else {
        hidePrivacyCover()
        return
      }
      observersRegistered = false

      NotificationCenter.default.removeObserver(self)
      hidePrivacyCover()
    }
  }

  @objc private func showPrivacyCover() {
    guard enabled, coverView == nil, let contentView = window?.contentView else {
      return
    }

    let cover = NSVisualEffectView()
    cover.translatesAutoresizingMaskIntoConstraints = false
    cover.material = .fullScreenUI
    cover.blendingMode = .withinWindow
    cover.state = .active
    cover.wantsLayer = true
    cover.layer?.backgroundColor = NSColor.separatorColor
      .withAlphaComponent(0.35)
      .cgColor

    contentView.addSubview(cover)
    NSLayoutConstraint.activate([
      cover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      cover.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      cover.topAnchor.constraint(equalTo: contentView.topAnchor),
      cover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])

    coverView = cover
  }

  @objc private func hidePrivacyCover() {
    coverView?.removeFromSuperview()
    coverView = nil
  }
}
