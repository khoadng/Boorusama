import Flutter
import UIKit

final class AppPrivacyChannel {
  private static let channelName = "app_privacy"

  private let channel: FlutterMethodChannel
  private var enabled = false
  private var observersRegistered = false
  private var coverView: UIView?

  init(messenger: FlutterBinaryMessenger) {
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
        name: UIApplication.willResignActiveNotification,
        object: nil
      )
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(showPrivacyCover),
        name: UIApplication.didEnterBackgroundNotification,
        object: nil
      )
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(hidePrivacyCover),
        name: UIApplication.didBecomeActiveNotification,
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
    guard enabled, coverView == nil else { return }

    let cover = UIVisualEffectView(
      effect: UIBlurEffect(style: .dark)
    )
    cover.translatesAutoresizingMaskIntoConstraints = false
    cover.contentView.backgroundColor = UIColor.systemFill.withAlphaComponent(0.35)

    for window in windows {
      window.addSubview(cover)
      NSLayoutConstraint.activate([
        cover.leadingAnchor.constraint(equalTo: window.leadingAnchor),
        cover.trailingAnchor.constraint(equalTo: window.trailingAnchor),
        cover.topAnchor.constraint(equalTo: window.topAnchor),
        cover.bottomAnchor.constraint(equalTo: window.bottomAnchor),
      ])
      break
    }

    coverView = cover
  }

  @objc private func hidePrivacyCover() {
    coverView?.removeFromSuperview()
    coverView = nil
  }

  private var windows: [UIWindow] {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
  }
}
