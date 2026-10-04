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

  for (final browserCookie in _newestPerScope(cookies)) {
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

/// A browser can hold two cookies with the same name, domain and path, such
/// as a partitioned and an unpartitioned copy. The browser picks between them
/// itself, but a request jar would send both. When the browser reports
/// creation times, keep only the newest; otherwise leave the choice to the
/// caller.
Iterable<BrowserCookie> _newestPerScope(List<BrowserCookie> cookies) {
  final groups = <(String, String, String), List<BrowserCookie>>{};
  for (final cookie in cookies) {
    final key = (
      cookie.name,
      cookie.domain.trim().toLowerCase(),
      cookie.path.isEmpty ? '/' : cookie.path,
    );
    (groups[key] ??= []).add(cookie);
  }
  return groups.values.expand(
    (group) => switch (group) {
      [_] => group,
      _ when group.every((cookie) => cookie.createdUtc != null) => [
        group.reduce(
          (a, b) => b.createdUtc!.isAfter(a.createdUtc!) ? b : a,
        ),
      ],
      _ => group,
    },
  );
}

bool _pathMatches(String requestPath, String cookiePath) {
  if (requestPath == cookiePath) return true;
  if (!requestPath.startsWith(cookiePath)) return false;
  if (cookiePath.endsWith('/')) return true;
  return requestPath.length > cookiePath.length &&
      requestPath[cookiePath.length] == '/';
}
