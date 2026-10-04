// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'types.dart';

/// Reads the cookies the platform WebView holds for a URL. On iOS and macOS
/// this includes the attributes webview_flutter drops.
class WebViewCookieChannel {
  const WebViewCookieChannel._();

  static const _channel = MethodChannel('webview_cookies');

  static Future<List<BrowserCookie>> getCookies(Uri uri) async {
    final results = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'getCookies',
      {'url': uri.toString()},
    );
    return [
      for (final result in results ?? const <Map<Object?, Object?>>[])
        ?_decode(result),
    ];
  }

  static BrowserCookie? _decode(Map<Object?, Object?> map) => switch (map) {
    {
      'name': final String name,
      'value': final String value,
      'domain': final String domain,
      'path': final String path,
    } =>
      BrowserCookie(
        name: name,
        value: value,
        domain: domain,
        path: path,
        expiresUtc: switch (map['expiresMs']) {
          final int ms => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
          _ => null,
        },
        isSecure: map['secure'] as bool?,
        isHttpOnly: map['httpOnly'] as bool?,
        sameSite: switch ((map['sameSite'] as String?)?.toLowerCase()) {
          'lax' => BrowserCookieSameSite.lax,
          'strict' => BrowserCookieSameSite.strict,
          'none' => BrowserCookieSameSite.none,
          _ => null,
        },
        createdUtc: switch (map['createdMs']) {
          final int ms => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
          _ => null,
        },
      ),
    _ => null,
  };
}
