// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:filename_generator/filename_generator.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../posts/post/types.dart';
import '../../../settings/types.dart';
import 'token_options.dart';

enum TokenType { sync, async }

class TokenInfo extends Equatable {
  const TokenInfo(
    this.name,
    this.type,
  );

  final String name;
  final TokenType type;

  @override
  List<Object?> get props => [name, type];
}

abstract class DownloadFilenameGenerator<T extends Post> {
  List<TokenInfo> get availableTokens;

  List<TextMatcher> get textMatchers;

  List<String> getTokenOptions(String token);
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption);

  Future<String> generate(
    Settings settings,
    BooruConfigDownload config,
    T post, {
    required String downloadUrl,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
  });

  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfigDownload config,
    T post, {
    required String downloadUrl,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
    Duration? asyncTokenDelay,
  });

  Future<PreloadResult> preloadForBulkDownload(
    List<T> posts,
    BooruConfigAuth config,
    BooruConfigDownload downloadConfig,
    CancelToken? cancelToken,
  );

  bool formatContainsAsyncToken(String? format);

  bool hasSlowBulkGeneration(String format);

  String generateSample(String format);

  List<String> generateSamples(String format);

  String get defaultFileNameFormat;
  String get defaultBulkDownloadFileNameFormat;
}

typedef DownloadFilenameTokenHandler<T extends Post> =
    String? Function(
      T post,
      DownloadFilenameTokenOptions options,
    );

typedef PreloadFunction = Future<void> Function();

sealed class PreloadResult {
  const PreloadResult();
}

class Sync extends PreloadResult {
  const Sync();
}

class AsyncNoPreload extends PreloadResult {
  const AsyncNoPreload();
}

class AsyncPreload extends PreloadResult {
  const AsyncPreload({required this.preload});

  factory AsyncPreload.noop() => AsyncPreload(preload: () async {});

  final PreloadFunction preload;
}

extension PreloadResultX on PreloadResult {
  bool get isAsyncNoPreload => this is AsyncNoPreload;
}
