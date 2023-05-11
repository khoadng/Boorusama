// Project imports:
import 'package:boorusama/functional.dart';
import 'source_utils.dart';

sealed class PostSource {
  const PostSource();

  factory PostSource.none() => const NoSource();

  factory PostSource.pixiv(int pixivId) => PixivSource(pixivId: pixivId);

  factory PostSource.from(
    String? value, {
    int? pixivId,
  }) {
    if (value == null || value.isEmpty) return const NoSource();

    return isWebSource(value)
        ? pixivId.toOption().fold(
              () => SimpleWebSource(uri: Uri.parse(value)),
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
  bool get hasIcoLogoSource => useIco(uri);

  String get url;
}

class SimpleWebSource extends WebSource {
  SimpleWebSource({
    required super.uri,
  });

  @override
  String get url => uri.toString();
}

const pixivLinkUrl = 'https://www.pixiv.net/en/artworks/';

class PixivSource extends WebSource {
  PixivSource({
    required int pixivId,
  }) : super(uri: Uri.parse('$pixivLinkUrl$pixivId'));

  @override
  String get url => uri.toString();
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
