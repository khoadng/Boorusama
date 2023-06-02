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
  final hostMappings = {
    'artstation.com': 'https://artstation.com',
    'discordapp.com': 'https://discordapp.com',
    'kym-cdn.com': 'https://knowyourmeme.com',
    'images-wixmp': 'https://deviantart.com',
    'fantia.jp': 'https://fantia.jp',
    'hentai-foundry.com': 'https://hentai-foundry.com',
    'exhentai.org': 'https://e-hentai.org',
    'ngfiles.com': 'https://newgrounds.com',
    'i.pximg.net': 'https://pixiv.net',
    'youtu.be': 'https://youtube.com',
    'tumblr.com': 'https://tumblr.com',
    'biligame.com': 'https://bilibili.com',
    'dlsite.jp': 'https://dlsite.jp',
  };

  for (final mapping in hostMappings.entries) {
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
