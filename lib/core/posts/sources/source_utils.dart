// Project imports:
import 'package:boorusama/functional.dart';
import 'source_def.dart';

bool isWebSource(String? url) {
  if (url == null || url.isEmpty) {
    return false;
  }

  // Check for a valid URL format
  final pattern = RegExp(
      r'^(https?:\/\/)?([a-z0-9-]+\.)+[a-z]{2,}(:[0-9]+)?([/?].*)?$',
      caseSensitive: false);
  if (!pattern.hasMatch(url)) {
    return false;
  }

  final uri = Uri.tryParse(url);

  if (uri == null) return false;

  return uri.scheme == 'http' || uri.scheme == 'https';
}

String getHost(Uri uri) {
  for (final mapping in getHosts().entries) {
    if (uri.host.contains(mapping.key)) {
      return mapping.value;
    }
  }

  return '${uri.scheme}://${uri.host}';
}

String _buildEndpoint(
  String url, {
  int? size,
}) =>
    'https://www.google.com/s2/favicons?domain=$url&sz=${size ?? 64}';

String _buildSourceUrl(Uri uri) => '${uri.scheme}://${uri.host}/';

String getFavicon(
  String url, {
  int? size,
}) =>
    tryParseUrl(url).fold(
      () => _buildEndpoint(url, size: size),
      (uri) => _buildEndpoint(_buildSourceUrl(uri), size: size),
    );
