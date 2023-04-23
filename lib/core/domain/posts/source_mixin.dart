mixin SourceMixin {
  String? get source;
  bool get hasWebSource => _isWebSource(source);
  String? get sourceHost => hasWebSource ? _getHost(Uri.parse(source!)) : null;
  bool get hasIcoLogoSource =>
      hasWebSource ? _useIco(Uri.parse(source!)) : false;

  bool _isWebSource(String? url) {
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
}

String _getHost(Uri uri) {
  if (uri.host.contains('artstation.com')) return 'artstation.com';
  if (uri.host.contains('discordapp.com')) return 'discordapp.com';
  if (uri.host.contains('kym-cdn.com')) return 'knowyourmeme.com';
  if (uri.host.contains('images-wixmp')) return 'deviantart.com';
  if (uri.host.contains('fantia.jp')) return 'fantia.jp';
  if (uri.host.contains('hentai-foundry.com')) return 'hentai-foundry.com';
  if (uri.host.contains('exhentai.org')) return 'e-hentai.org';
  if (uri.host.contains('ngfiles.com')) return 'newgrounds.com';
  if (uri.host.contains('i.pximg.net')) return 'pixiv.net';
  if (uri.host.contains('lofter.com')) {
    return 'https://www.lofter.com/favicon.ico';
  }

  return uri.host;
}

bool _useIco(Uri uri) {
  if (uri.host.contains('lofter.com')) return true;
  return false;
}
