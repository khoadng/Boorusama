// Package imports:
import 'package:coreutils/coreutils.dart';

// Project imports:
import 'types.dart';

List<Cookie> browserCookiesForRequest({
  required Uri uri,
  required List<BrowserCookie> cookies,
  required DateTime now,
}) {
  if ((uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) {
    return const [];
  }

  final host = uri.host.toLowerCase();
  final requestPath = uri.path.isEmpty ? '/' : uri.path;
  final result = <Cookie>[];

  for (final browserCookie in cookies) {
    if (browserCookie.name.isEmpty) continue;
    final expires = browserCookie.expiresUtc?.toUtc();
    if (expires != null && !expires.isAfter(now.toUtc())) continue;
    if ((browserCookie.isSecure ?? false) && uri.scheme != 'https') continue;

    final rawDomain = browserCookie.domain.trim().toLowerCase();
    final comparisonDomain = rawDomain.startsWith('.')
        ? rawDomain.substring(1)
        : rawDomain;
    if (comparisonDomain.isNotEmpty &&
        host != comparisonDomain &&
        !host.endsWith('.$comparisonDomain')) {
      continue;
    }

    final path = browserCookie.path.isEmpty ? '/' : browserCookie.path;
    if (!_pathMatches(requestPath, path)) continue;

    final cookie = Cookie(browserCookie.name, browserCookie.value)
      ..path = path
      ..expires = expires
      ..secure = browserCookie.isSecure ?? false
      ..httpOnly = browserCookie.isHttpOnly ?? false;

    // A native cookie with an undotted domain is ambiguous across the mobile
    // and Windows adapters. Keep it host-only by leaving Cookie.domain unset.
    // Leading-dot domains retain their explicit shared scope.
    if (rawDomain.startsWith('.')) cookie.domain = rawDomain;
    result.add(cookie);
  }

  return result;
}

bool _pathMatches(String requestPath, String cookiePath) {
  if (requestPath == cookiePath) return true;
  if (!requestPath.startsWith(cookiePath)) return false;
  if (cookiePath.endsWith('/')) return true;
  return requestPath.length > cookiePath.length &&
      requestPath[cookiePath.length] == '/';
}
