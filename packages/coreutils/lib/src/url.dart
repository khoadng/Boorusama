import 'package:path/path.dart' as p;

String normalizeUrl(String? url) {
  return switch (url) {
    null || '' => url ?? '',
    _ => switch (Uri.tryParse(url)) {
      null => '',
      // Handle edge case where URL has no scheme/host (e.g., "?token=abc")
      Uri(scheme: '', host: '', path: '') => '',
      final uri => Uri(
        scheme: uri.scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path,
      ).toString(),
    },
  };
}

String urlExtension(String? url) {
  final sanitized = normalizeUrl(url);
  return p.extension(sanitized);
}
