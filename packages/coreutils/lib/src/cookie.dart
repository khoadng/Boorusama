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

  /// Parses a list of Set-Cookie response headers into a map of cookie
  /// name-value pairs, extracting only the cookie value from each header
  /// (ignoring attributes like path, domain, expires, etc.).
  static Map<String, String> extractValuesFromSetCookieHeaders(
    List<String> headers,
  ) {
    final cookies = <String, String>{};
    for (final parsed in _parseSetCookieHeaders(headers)) {
      cookies[parsed.name] = parsed.value;
    }
    return cookies;
  }

  /// Extracts the expiry date from a Set-Cookie header for a given cookie name.
  ///
  /// Parses `Expires` attribute or calculates from `Max-Age` if present.
  /// Returns null if the cookie is not found or has no expiry info.
  static DateTime? extractExpiryFromSetCookieHeaders(
    List<String> headers,
    String cookieName,
  ) {
    for (final parsed in _parseSetCookieHeaders(headers)) {
      if (parsed.name != cookieName) continue;

      final maxAge = parsed.attributes['max-age'];
      if (maxAge != null) {
        final seconds = int.tryParse(maxAge);
        if (seconds != null) {
          return DateTime.now().add(Duration(seconds: seconds));
        }
      }

      final expires = parsed.attributes['expires'];
      if (expires != null) return _parseHttpDate(expires);

      return null;
    }
    return null;
  }

  static Iterable<_ParsedSetCookie> _parseSetCookieHeaders(
    List<String> headers,
  ) sync* {
    for (final header in headers) {
      final parts = header.split(';');
      final cookiePart = parts.first.split('=');
      if (cookiePart.length < 2) continue;

      final name = cookiePart[0].trim();
      if (name.isEmpty) continue;

      final value = cookiePart.sublist(1).join('=').trim();
      final attributes = <String, String>{};
      for (final part in parts.skip(1)) {
        final kv = part.split('=');
        final key = kv[0].trim().toLowerCase();
        final val = kv.length >= 2 ? kv.sublist(1).join('=').trim() : '';
        attributes[key] = val;
      }

      yield _ParsedSetCookie(name: name, value: value, attributes: attributes);
    }
  }

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  /// Parses an HTTP date string (RFC 1123).
  /// e.g. "Thu, 01 Jan 2026 00:00:00 GMT"
  static DateTime? _parseHttpDate(String dateStr) {
    try {
      final parts = dateStr.trim().split(RegExp(r'[\s,:-]+'));
      if (parts.length < 7) return null;

      final day = int.parse(parts[1]);
      final month = _months[parts[2].toLowerCase()];
      final year = int.parse(parts[3]);
      final hour = int.parse(parts[4]);
      final minute = int.parse(parts[5]);
      final second = int.parse(parts[6]);

      if (month == null) return null;

      return DateTime.utc(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  static Cookie fromSetCookieValue(String setCookieValue) {
    return Cookie.fromSetCookieValue(setCookieValue);
  }
}

class _ParsedSetCookie {
  const _ParsedSetCookie({
    required this.name,
    required this.value,
    required this.attributes,
  });

  final String name;
  final String value;
  final Map<String, String> attributes;
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
}
