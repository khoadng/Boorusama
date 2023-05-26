// Project imports:
import 'package:boorusama/functional.dart';

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

  var uri = Uri.tryParse(url);

  if (uri == null) return false;

  return uri.scheme == 'http' || uri.scheme == 'https';
}

String getHost(Uri uri) {
  if (uri.host.contains('artstation.com')) return 'https://artstation.com';
  if (uri.host.contains('discordapp.com')) return 'https://discordapp.com';
  if (uri.host.contains('kym-cdn.com')) return 'https://knowyourmeme.com';
  if (uri.host.contains('images-wixmp')) return 'https://deviantart.com';
  if (uri.host.contains('fantia.jp')) return 'https://fantia.jp';
  if (uri.host.contains('hentai-foundry.com')) {
    return 'https://hentai-foundry.com';
  }
  if (uri.host.contains('exhentai.org')) return 'https://e-hentai.org';
  if (uri.host.contains('ngfiles.com')) return 'https://newgrounds.com';
  if (uri.host.contains('i.pximg.net')) return 'https://pixiv.net';
  if (uri.host.contains('youtu.be')) return 'https://youtube.com';

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
