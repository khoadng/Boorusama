// Project imports:
import 'package:boorusama/functional.dart';
import 'source_utils.dart';

sealed class PostSource {
  const PostSource();

  factory PostSource.from(
    String? value, {
    int? pixivId,
  }) {
    if (value == null || value.isEmpty) return const NoSource();

    return isWebSource(value)
        ? pixivId.toOption().fold(
              () => RawWebSource(
                faviconUrl: _getFavicon(value),
                url: value,
                uri: Uri.parse(value),
              ),
              (pixivId) => PostSource.pixiv(pixivId),
            )
        : NonWebSource(value);
  }

  factory PostSource.none() => const NoSource();

  factory PostSource.pixiv(int pixivId) => PixivSource(pixivId: pixivId);

  static final IMap<String, String> customFaviconUrlSite = <String, String>{
    'lofter': 'https://www.lofter.com/favicon.ico',
    'lolibooru': 'https://lolibooru.moe/favicon.ico',
    'e926': 'https://www.e926.net/favicon.ico',
    'sketch.pixiv': 'https://sketch.pixiv.net/favicon.ico',
    'pixiv.me': 'https://www.pixiv.net/favicon.ico',
  }.lock;

  static final IMap<String, String> assetFaviconUrlSite = <String, String>{
    'donmai': 'assets/images/danbooru-logo.png',
  }.lock;

  static String? _getFavicon(String host) {
    for (final entry in assetFaviconUrlSite.entries) {
      if (host.contains(entry.key)) {
        return entry.value;
      }
    }

    for (final entry in customFaviconUrlSite.entries) {
      if (host.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }
}

class NonWebSource extends PostSource {
  const NonWebSource(this.value);

  final String value;
}

class NoSource extends PostSource {
  const NoSource();
}

sealed class WebSource extends PostSource {
  WebSource({
    required this.uri,
  });

  final Uri uri;
  String get sourceHost => getHost(uri);
  String get faviconUrl;

  String get url;
}

enum FaviconType {
  asset,
  network,
}

class RawWebSource extends WebSource {
  RawWebSource({
    required String? faviconUrl,
    required this.url,
    required super.uri,
  }) : _faviconUrl = faviconUrl;

  final String? _faviconUrl;

  @override
  String get faviconUrl => _faviconUrl ?? getFavicon(sourceHost);

  @override
  final String url;
}

const pixivLinkUrl = 'https://www.pixiv.net/en/artworks/';

class PixivSource extends WebSource {
  PixivSource({
    required int pixivId,
  }) : super(uri: Uri.parse('$pixivLinkUrl$pixivId'));

  @override
  String get url => uri.toString();

  @override
  String get faviconUrl => getFavicon(sourceHost);
}

extension PostSourceX on PostSource {
  bool get isNoSource => this is NoSource;
  bool get isWebSource => this is WebSource;
  bool get isNonWebSource => this is NonWebSource;
  bool get isPixivSource => this is PixivSource;

  String? get url => whenWeb(
        (source) => source.url,
        () => null,
      );

  T whenWeb<T>(
    T Function(WebSource source) onWeb,
    T Function() orElse,
  ) =>
      switch (this) {
        final WebSource s => onWeb(s),
        _ => orElse(),
      };
}

extension WebSourceX on WebSource {
  FaviconType get faviconType =>
      faviconUrl.startsWith('assets') ? FaviconType.asset : FaviconType.network;
}
