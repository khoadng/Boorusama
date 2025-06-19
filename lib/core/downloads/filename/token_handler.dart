// Project imports:
import '../../posts/post/post.dart';
import 'generator.dart';
import 'token_options.dart';

class TokenHandler<T extends Post> {
  const TokenHandler(this.key, this._handler);

  final String key;
  final DownloadFilenameTokenHandler<T> _handler;

  String? call(T post, DownloadFilenameTokenOptions options) {
    return _handler(post, options);
  }

  DownloadFilenameTokenHandler<T> get handler => _handler;

  MapEntry<String, DownloadFilenameTokenHandler<T>> toMapEntry() {
    return MapEntry(key, _handler);
  }
}

extension TokenHandlerListX<T extends Post> on List<TokenHandler<T>> {
  Map<String, DownloadFilenameTokenHandler<T>> toMap() {
    final result = <String, DownloadFilenameTokenHandler<T>>{};
    for (final token in this) {
      if (result.containsKey(token.key)) {
        throw ArgumentError('Duplicate token key: ${token.key}');
      }
      result[token.key] = token.handler;
    }
    return result;
  }
}

class WidthTokenHandler<T extends Post> extends TokenHandler<T> {
  WidthTokenHandler() : super('width', (post, config) => post.width.toString());
}

class HeightTokenHandler<T extends Post> extends TokenHandler<T> {
  HeightTokenHandler()
      : super('height', (post, config) => post.height.toString());
}

class AspectRatioTokenHandler<T extends Post> extends TokenHandler<T> {
  AspectRatioTokenHandler()
      : super('aspect_ratio', (post, config) => post.aspectRatio.toString());
}

class MPixelsTokenHandler<T extends Post> extends TokenHandler<T> {
  MPixelsTokenHandler()
      : super('mpixels', (post, config) => post.mpixels.toString());
}
