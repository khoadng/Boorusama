// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/filename_generators/filename_generator.dart';
import 'package:boorusama/core/feats/filename_generators/token.dart';
import 'package:boorusama/core/feats/filename_generators/token_option.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/functional.dart';

abstract class DownloadFilenameGenerator<T extends Post> {
  Set<String> get availableTokens;

  Map<RegExp, TextStyle> get patternMatchMap;

  List<String> getTokenOptions(String token);
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption);

  String generate(
    Settings settings,
    BooruConfig config,
    T post,
  );

  String generateForBulkDownload(
    Settings settings,
    BooruConfig config,
    T post, {
    int? index,
  });

  String generateSample(String format);

  List<String> generateSamples(String format);

  String get defaultFileNameFormat;
  String get defaultBulkDownloadFileNameFormat;
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
  Set<String> get availableTokens => {};

  final String Function(T post, String downloadUrl) generateFileName;

  @override
  String generate(
    Settings settings,
    BooruConfig config,
    T post,
  ) {
    final downloadUrl = getDownloadFileUrl(post, settings);

    return generateFileName(post, downloadUrl);
  }

  @override
  String generateForBulkDownload(Settings settings, BooruConfig config, T post,
      {int? index}) {
    final downloadUrl = getDownloadFileUrl(post, settings);

    return generateFileName(post, downloadUrl);
  }

  @override
  String generateSample(String format) => '';

  @override
  List<String> generateSamples(String format) => [];

  @override
  List<String> getTokenOptions(String token) => [];

  @override
  Map<RegExp, TextStyle> get patternMatchMap => {};

  @override
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption) =>
      null;

  @override
  String get defaultBulkDownloadFileNameFormat => '';

  @override
  String get defaultFileNameFormat => '';
}

class DownloadFileNameBuilder<T extends Post>
    implements DownloadFilenameGenerator<T> {
  DownloadFileNameBuilder({
    required this.tokenHandlers,
    required this.sampleData,
    required this.defaultFileNameFormat,
    required this.defaultBulkDownloadFileNameFormat,
  });

  final List<Map<String, String>> sampleData;

  @override
  Set<String> get availableTokens => {
        ...tokenHandlers.keys,
        'date',
        'uuid',
      }.toSet();

  final Map<String, DownloadFilenameTokenHandler<T>> tokenHandlers;

  final TokenizerConfigs tokenizerConfigs = TokenizerConfigs.defaultConfigs();

  String _generate(
    Settings settings,
    BooruConfig config,
    String? format,
    T post, {
    int? index,
  }) {
    final downloadUrl = getDownloadFileUrl(post, settings);
    final fallbackName = basename(downloadUrl);

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
  String generate(
    Settings settings,
    BooruConfig config,
    T post,
  ) =>
      _generate(
        settings,
        config,
        config.customDownloadFileNameFormat,
        post,
      );

  @override
  String generateForBulkDownload(
    Settings settings,
    BooruConfig config,
    T post, {
    int? index,
  }) =>
      _generate(
        settings,
        config,
        config.customBulkDownloadFileNameFormat,
        post,
        index: index,
      );

  @override
  List<String> getTokenOptions(String token) {
    final tokenDef = tokenizerConfigs.tokenOptionsOf(token);

    if (tokenDef == null) return [];

    return tokenDef;
  }

  @override
  Map<RegExp, TextStyle> get patternMatchMap => {
        for (final token in availableTokens)
          RegExp('{($token[^{}]*?)}'): TextStyle(
            fontWeight: FontWeight.w700,
            color: switch (token) {
              'artist' => const Color.fromARGB(255, 255, 138, 139),
              'character' => const Color.fromARGB(255, 53, 198, 74),
              'copyright' => const Color.fromARGB(255, 199, 151, 255),
              'general' => const Color.fromARGB(255, 0, 155, 230),
              'meta' => const Color.fromARGB(255, 217, 187, 98),
              'species' => const Color(0xffed5d1f),
              'extension' => const Color.fromARGB(255, 204, 143, 180),
              'md5' => const Color.fromARGB(255, 204, 143, 180),
              'date' => const Color.fromARGB(255, 73, 170, 190),
              'index' => const Color.fromARGB(255, 176, 86, 182),
              'width' => const Color.fromARGB(255, 176, 86, 182),
              'height' => const Color.fromARGB(255, 176, 86, 182),
              'mpixels' => const Color.fromARGB(255, 176, 86, 182),
              'aspect_ratio' => const Color.fromARGB(255, 176, 86, 182),
              'id' => const Color.fromARGB(255, 176, 86, 182),
              _ => const Color.fromARGB(255, 0, 155, 230),
            },
          ),
      };

  @override
  String generateSample(String format) => sampleData.firstOption.fold(
        () => '',
        (data) => _generateSample(data, format),
      );

  @override
  List<String> generateSamples(String format) =>
      sampleData.map((data) => _generateSample(data, format)).toList();

  String _generateSample(
    Map<String, String> data,
    String format,
  ) {
    final downloadUrl = data['source'];
    final fallbackName = downloadUrl != null ? basename(downloadUrl) : null;

    final filename = generateFileName(
      data,
      format,
      configs: tokenizerConfigs,
    );

    return filename.isNotEmpty ? filename : fallbackName ?? '';
  }

  @override
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption) {
    return tokenizerConfigs.tokenOptionDocsOf(token, tokenOption);
  }

  @override
  final String defaultBulkDownloadFileNameFormat;

  @override
  final String defaultFileNameFormat;
}
