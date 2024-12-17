// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filename_generator/filename_generator.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../configs/config.dart';
import '../../foundation/path.dart';
import '../../posts/post/post.dart';
import '../../settings/settings.dart';
import '../urls/sanitizer.dart';
import 'generator.dart';
import 'token_options.dart';

class DownloadFileNameBuilder<T extends Post>
    implements DownloadFilenameGenerator<T> {
  DownloadFileNameBuilder({
    required Map<String, DownloadFilenameTokenHandler<T>> tokenHandlers,
    required this.sampleData,
    required this.defaultFileNameFormat,
    required this.defaultBulkDownloadFileNameFormat,
    bool hasRating = true,
    bool hasMd5 = true,
    DownloadFilenameTokenHandler<T>? extensionHandler,
  }) {
    this.tokenHandlers = {
      'id': (post, config) => post.id.toString(),
      'tags': (post, config) => post.tags.join(' '),
      'extension': extensionHandler ??
          (post, config) => sanitizedExtension(config.downloadUrl).substring(1),
      if (hasMd5) 'md5': (post, config) => post.md5,
      if (hasRating) 'rating': (post, config) => post.rating.name,
      'index': (post, config) => config.index?.toString(),
      'search': (post, config) => post.metadata?.search,
      ...tokenHandlers,
    };
  }

  final List<Map<String, String>> sampleData;

  @override
  Set<String> get availableTokens => {
        ...tokenHandlers.keys,
        'date',
        'uuid',
      }.toSet();

  late final Map<String, DownloadFilenameTokenHandler<T>> tokenHandlers;

  final TokenizerConfigs tokenizerConfigs = TokenizerConfigs.defaultConfigs();

  String _joinFileWithExtension(String fileName, String fileExt) {
    // check if file already has extension
    final fileNameExt = extension(fileName);
    if (fileNameExt.isNotEmpty) return fileName;

    if (fileExt.isEmpty) return fileName;

    final ext = fileExt.startsWith('.') ? fileExt : '.$fileExt';

    // make sure to clean up the file name to avoid invalid file names
    final cleanedFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    return cleanedFileName.endsWith(ext)
        ? cleanedFileName
        : '$cleanedFileName$ext';
  }

  Future<String> _generate(
    Settings settings,
    BooruConfig config,
    String? format,
    T post, {
    required Map<String, String>? metadata,
    required String downloadUrl,
  }) async {
    final fallbackName = basename(downloadUrl);

    if (format == null || format.isEmpty) {
      return _joinFileWithExtension(fallbackName, post.format);
    }

    final options = DownloadFilenameTokenOptions(
      downloadUrl: downloadUrl,
      fallbackFilename: fallbackName,
      format: format,
      metadata: metadata,
    );

    final fileName = generateFileName(
      {
        for (final token in tokenHandlers.keys)
          token: tokenHandlers[token]!(post, options),
      },
      format,
      configs: tokenizerConfigs,
    );

    if (fileName.isEmpty) {
      return _joinFileWithExtension(fallbackName, post.format);
    }

    return fileName;
  }

  @override
  Future<String> generate(
    Settings settings,
    BooruConfig config,
    T post, {
    Map<String, String>? metadata,
    required String downloadUrl,
  }) =>
      _generate(
        settings,
        config,
        config.customDownloadFileNameFormat,
        post,
        metadata: metadata,
        downloadUrl: downloadUrl,
      );

  @override
  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfig config,
    T post, {
    Map<String, String>? metadata,
    required String downloadUrl,
  }) =>
      _generate(
        settings,
        config,
        config.customBulkDownloadFileNameFormat,
        post,
        metadata: metadata,
        downloadUrl: downloadUrl,
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
