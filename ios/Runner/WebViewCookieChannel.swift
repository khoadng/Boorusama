#if os(iOS)
import Flutter
#else
import FlutterMacOS
#endif
import WebKit

/// Reads cookies from the WebView's default store with all their attributes.
/// webview_flutter only returns name, value, domain and path, which is not
/// enough to tell duplicate clearance cookies apart.
final class WebViewCookieChannel {
  private static let channelName = "webview_cookies"

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
  }

  func register() {
    channel.setMethodCallHandler { call, result in
      let arguments = call.arguments as? [String: Any]
      switch call.method {
      case "getCookies":
        guard let host = Self.host(arguments?["url"]) else {
          result(Self.invalidArguments(call.method))
          return
        }
        Self.cookies(matching: host) { cookies in
          result(cookies.map(Self.encode))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static var store: WKHTTPCookieStore {
    WKWebsiteDataStore.default().httpCookieStore
  }

  private static func host(_ url: Any?) -> String? {
    guard let url = url as? String, let host = URL(string: url)?.host,
      !host.isEmpty
    else { return nil }
    return host.lowercased()
  }

  private static func cookies(
    matching host: String,
    completion: @escaping ([HTTPCookie]) -> Void
  ) {
    store.getAllCookies { cookies in
      completion(
        cookies.filter { cookie in
          var domain = cookie.domain.lowercased()
          if domain.hasPrefix(".") { domain.removeFirst() }
          return host == domain || host.hasSuffix(".\(domain)")
        })
    }
  }

  private static func encode(_ cookie: HTTPCookie) -> [String: Any?] {
    [
      "name": cookie.name,
      "value": cookie.value,
      "domain": cookie.domain,
      "path": cookie.path,
      "expiresMs": cookie.expiresDate.map {
        Int64($0.timeIntervalSince1970 * 1000)
      },
      "secure": cookie.isSecure,
      "httpOnly": cookie.isHTTPOnly,
      "sameSite": cookie.sameSitePolicy?.rawValue,
      // Duplicates of one cookie can share name, domain and path when one of
      // them is partitioned; creation time tells which is current.
      "createdMs": createdMs(cookie),
    ]
  }

  private static let createdKey = HTTPCookiePropertyKey("Created")

  // Not a documented key; its value is a Date or seconds since 2001.
  private static func createdMs(_ cookie: HTTPCookie) -> Int64? {
    switch cookie.properties?[createdKey] {
    case let date as Date:
      return Int64(date.timeIntervalSince1970 * 1000)
    case let seconds as NSNumber:
      return Int64(
        Date(timeIntervalSinceReferenceDate: seconds.doubleValue)
          .timeIntervalSince1970 * 1000)
    default:
      return nil
    }
  }

  private static func invalidArguments(_ method: String) -> FlutterError {
    FlutterError(
      code: "INVALID_ARGUMENTS",
      message: "Invalid arguments for \(method)",
      details: nil
    )
  }
}
