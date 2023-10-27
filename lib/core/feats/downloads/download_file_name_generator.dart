import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/filename_generators/filename_generator.dart';
import 'package:boorusama/core/feats/filename_generators/token.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

abstract class DownloadFilenameGenerator<T extends Post> {
  List<String> get availableTokens;

  List<String> getTokenOptions(String token);

  String generate(
    Settings settings,
    BooruConfig config,
    T post, {
    int? index,
  });
}

typedef DownloadFilenameTokenHandler<T extends Post> = String? Function(
  T post,
  DownloadFilenameTokenOptions options,
);

class DownloadFilenameTokenOptions extends Equatable {
  const DownloadFilenameTokenOptions({
    required this.downloadUrl,
    required this.fallbackFilename,
    required this.format,
    this.index,
  });

  final String downloadUrl;
  final String fallbackFilename;
  final String format;
  final int? index;

  @override
  List<Object?> get props => [downloadUrl, fallbackFilename, format, index];
}

class LegacyFilenameBuilder<T extends Post>
    implements DownloadFilenameGenerator<T> {
  LegacyFilenameBuilder({
    required this.generateFileName,
  });

  @override
  List<String> get availableTokens => [];

  final String Function(T post, String downloadUrl) generateFileName;

  @override
  String generate(
    Settings settings,
    BooruConfig config,
    T post, {
    int? index,
  }) {
    final downloadUrl = getDownloadFileUrl(post, settings);

    return generateFileName(post, downloadUrl);
  }

  @override
  List<String> getTokenOptions(String token) => [];
}

class DownloadFileNameBuilder<T extends Post>
    implements DownloadFilenameGenerator<T> {
  DownloadFileNameBuilder({
    required this.tokenHandlers,
  });

  @override
  List<String> get availableTokens => tokenHandlers.keys.toList();

  final Map<String, DownloadFilenameTokenHandler<T>> tokenHandlers;

  final TokenizerConfigs tokenizerConfigs = TokenizerConfigs.defaultConfigs();

  @override
  String generate(
    Settings settings,
    BooruConfig config,
    T post, {
    int? index,
  }) {
    final downloadUrl = getDownloadFileUrl(post, settings);
    final fallbackName = basename(downloadUrl);
    final format = config.customDownloadFileNameFormat;

    if (format == null || format.isEmpty) return fallbackName;

    final options = DownloadFilenameTokenOptions(
      downloadUrl: downloadUrl,
      fallbackFilename: fallbackName,
      format: format,
      index: index,
    );

    final fileName = generateFileName(
      {
        for (final token in tokenHandlers.keys)
          token: tokenHandlers[token]!(post, options),
      },
      format,
      configs: tokenizerConfigs,
    );

    if (fileName.isEmpty) return fallbackName;

    return fileName;
  }

  @override
  List<String> getTokenOptions(String token) {
    final tokenDef = tokenizerConfigs.tokenDefinitions[token];

    if (tokenDef == null) return [];

    return tokenDef;
  }
}
