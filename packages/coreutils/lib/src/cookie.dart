// Package imports:
import 'package:cookie_jar/cookie_jar.dart';

class CookieUtils {
  CookieUtils._();

  /// Parses a cookie header string into a map of key-value pairs
  ///
  /// Example: "session=abc123; theme=dark" -> {"session": "abc123", "theme": "dark"}
  static Map<String, String> parseCookieHeader(String cookieHeader) {
    final cookies = <String, String>{};

    for (final cookie in cookieHeader.split(';')) {
      final parts = cookie.trim().split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts
            .sublist(1)
            .join('=')
            .trim(); // Handle values with '=' in them
        if (key.isNotEmpty) {
          cookies[key] = value;
        }
      }
    }

    return cookies;
  }

  /// Formats a map of cookies into a cookie header string
  ///
  /// Example: {"session": "abc123", "theme": "dark"} -> "session=abc123; theme=dark"
  static String formatCookieHeader(Map<String, String> cookies) {
    return cookies.entries
        .where((entry) => entry.key.isNotEmpty)
        .map((entry) => '${entry.key}=${entry.value}')
        .join('; ');
  }

  /// Merges two cookie header strings, with the second taking precedence over the first
  ///
  /// Example:
  /// existing: "session=old; theme=dark"
  /// toMerge: "session=new; user=john"
  /// Result: "theme=dark; session=new; user=john"
  static String mergeCookieHeaders(
    String existingCookies,
    String cookiesToMerge,
  ) {
    if (existingCookies.isEmpty) return cookiesToMerge;
    if (cookiesToMerge.isEmpty) return existingCookies;

    final existingMap = parseCookieHeader(existingCookies);
    final mergeMap = parseCookieHeader(cookiesToMerge);

    // Merge with toMerge taking precedence
    final mergedCookies = <String, String>{
      ...existingMap,
      ...mergeMap,
    };

    return formatCookieHeader(mergedCookies);
  }
}

/// Extensions for cookie_jar Cookie objects
extension CookieJarExtensions on List<Cookie> {
  String get cookieString => map((cookie) => cookie.toString()).join('; ');

  Map<String, String> get cookieMap {
    final map = <String, String>{};
    for (final cookie in this) {
      map[cookie.name] = cookie.value;
    }
    return map;
  }

  String? getCookieValue(String name) {
    for (final cookie in this) {
      if (cookie.name == name) {
        return cookie.value;
      }
    }
    return null;
  }

  bool hasCookie(String name) {
    return any((cookie) => cookie.name == name);
  }
}
