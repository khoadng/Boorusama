// Project imports:
import 'package:boorusama/functional.dart';
import 'source_utils.dart';

sealed class PostSource {
  const PostSource();

  factory PostSource.none() => const NoSource();

  factory PostSource.pixiv(int pixivId) => PixivSource(pixivId: pixivId);

  static final IMap<String, String> customFaviconUrlSite = <String, String>{
    'lofter': 'https://www.lofter.com/favicon.ico',
    'lolibooru': 'https://lolibooru.moe/favicon.ico',
    'e926': 'https://www.e926.net/favicon.ico',
  }.lock;

  factory PostSource.from(
    String? value, {
    int? pixivId,
  }) {
    if (value == null || value.isEmpty) return const NoSource();

    return isWebSource(value)
        ? pixivId.toOption().fold(
            () {
              for (var key in customFaviconUrlSite.keys) {
                if (value.contains(key)) {
                  return RawWebSource(
                    faviconUrl: customFaviconUrlSite[key]!,
                    url: value,
                    hasCustomFaviconUrl: true,
                    uri: Uri.parse(value),
                  );
                }
              }

              return SimpleWebSource(uri: Uri.parse(value));
            },
            (pixivId) => PostSource.pixiv(pixivId),
          )
        : NonWebSource(value);
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
  bool get hasCustomFaviconUrl;

  String get url;
}

class RawWebSource extends WebSource {
  RawWebSource({
    required this.faviconUrl,
    required this.url,
    required this.hasCustomFaviconUrl,
    required super.uri,
  });

  @override
  final String faviconUrl;

  @override
  final String url;

  @override
  final bool hasCustomFaviconUrl;
}

class SimpleWebSource extends WebSource {
  SimpleWebSource({
    required super.uri,
  });

  @override
  String get url => uri.toString();

  @override
  String get faviconUrl => getFavicon(sourceHost);

  @override
  bool get hasCustomFaviconUrl => false;
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

  @override
  bool get hasCustomFaviconUrl => false;
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
        WebSource s => onWeb(s),
        _ => orElse(),
      };
}
