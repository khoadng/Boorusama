// Project imports:
import 'package:boorusama/functional.dart';

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
