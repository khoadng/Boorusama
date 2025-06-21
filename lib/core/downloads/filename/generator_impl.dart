// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filename_generator/filename_generator.dart';
import 'package:foundation/foundation.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../configs/config.dart';
import '../../foundation/path.dart';
import '../../posts/post/post.dart';
import '../../settings/settings.dart';
import '../urls/sanitizer.dart';
import 'async_token_resolver.dart';
import 'generator.dart';
import 'token_handler.dart';
import 'token_options.dart';

class DownloadFileNameBuilder<T extends Post>
    implements DownloadFilenameGenerator<T> {
  DownloadFileNameBuilder({
    required List<TokenHandler<T>> tokenHandlers,
    required this.sampleData,
    required this.defaultFileNameFormat,
    required this.defaultBulkDownloadFileNameFormat,
    this.asyncTokenHandlers = const [],
    bool hasRating = true,
    bool hasMd5 = true,
    DownloadFilenameTokenHandler<T>? extensionHandler,
  }) {
    final customHandlers = tokenHandlers.toMap();

    baseTokenHandlers = {
      'id': (post, config) => post.id.toString(),
      'tags': (post, config) => post.tags.join(' '),
      'extension': extensionHandler ??
          (post, config) => sanitizedExtension(config.downloadUrl).substring(1),
      if (hasMd5) 'md5': (post, config) => post.md5,
      if (hasRating) 'rating': (post, config) => post.rating.name,
      'index': (post, config) => config.index?.toString(),
      'search': (post, config) => post.metadata?.search,
      'source': (post, config) => config.downloadUrl,
      ...customHandlers,
    };

    // Group async handlers by groupKey
    _asyncResolverGroups = <String, AsyncTokenResolver<T>>{};
    for (final handler in asyncTokenHandlers) {
      _asyncResolverGroups[handler.groupKey] = handler.resolver;
    }
  }

  final List<Map<String, String>> sampleData;
  late final Map<String, DownloadFilenameTokenHandler<T>> baseTokenHandlers;
  late final List<AsyncTokenHandler<T>> asyncTokenHandlers;
  late final Map<String, AsyncTokenResolver<T>> _asyncResolverGroups;

  // Cache for resolved async tokens: postId -> groupKey -> resolved data
  final Map<String, Map<String, Map<String, String?>>> _asyncCache = {};

  final TokenizerConfigs tokenizerConfigs = TokenizerConfigs.defaultConfigs();

  @override
  Set<String> get availableTokens => {
        ...baseTokenHandlers.keys,
        ...asyncTokenHandlers.expand((h) => h.tokenKeys),
        'date',
        'uuid',
      }.toSet();

  String _joinFileWithExtension(String rawFileName, String fileExt) {
    final fileName = sanitizedUrl(rawFileName);

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

  Future<Map<String, String?>> _resolveAsyncTokens(
    T post,
    DownloadFilenameTokenOptions options,
  ) async {
    final postId = post.id.toString();

    // Initialize cache for this post if not exists
    _asyncCache[postId] ??= {};

    final result = <String, String?>{};
    final pendingGroups = <String, Future<Map<String, String?>>>{};

    // Process all async groups
    for (final groupKey in _asyncResolverGroups.keys) {
      if (_asyncCache[postId]![groupKey] != null) {
        // Use cached data
        result.addAll(_asyncCache[postId]![groupKey]!);
      } else {
        // Start async resolution
        final resolver = _asyncResolverGroups[groupKey]!;
        pendingGroups[groupKey] =
            resolver.resolve(post, options).catchError((error) {
          // Fallback to empty on error
          return <String, String?>{
            for (final token in resolver.tokenKeys) token: '',
          };
        });
      }
    }

    // Wait for all pending groups and cache results
    for (final entry in pendingGroups.entries) {
      final groupKey = entry.key;
      final resolvedData = await entry.value;

      // Cache the resolved data
      _asyncCache[postId]![groupKey] = resolvedData;
      result.addAll(resolvedData);
    }

    return result;
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

    // Resolve async tokens if any exist
    final asyncTokenValues = asyncTokenHandlers.isNotEmpty
        ? await _resolveAsyncTokens(post, options)
        : <String, String?>{};

    // Create complete token handlers map (sync + resolved async)
    final allTokenHandlers = <String, DownloadFilenameTokenHandler<T>>{
      ...baseTokenHandlers,
      // Add async tokens as sync handlers with resolved values
      for (final entry in asyncTokenValues.entries)
        entry.key: (_, __) => entry.value,
    };

    final fileName = generateFileName(
      {
        for (final token in allTokenHandlers.keys)
          token: allTokenHandlers[token]!(post, options),
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
    required String downloadUrl,
    Map<String, String>? metadata,
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
    required String downloadUrl,
    Map<String, String>? metadata,
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
  List<TextMatcher> get textMatchers => [
        for (final token in availableTokens)
          RegexMatcher(
            pattern: RegExp('{($token[^{}]*?)}'),
            spanBuilder: (match) => TextSpan(
              text: match.text,
              style: TextStyle(
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
            ),
          ),
      ];

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

const fallbackFileNameFormat = '{uuid:version=1}.{extension}';
final fallbackFileNameBuilder = DownloadFileNameBuilder<Post>(
  defaultFileNameFormat: fallbackFileNameFormat,
  defaultBulkDownloadFileNameFormat: fallbackFileNameFormat,
  sampleData: [],
  hasRating: false,
  extensionHandler: (post, config) =>
      post.format.startsWith('.') ? post.format.substring(1) : post.format,
  tokenHandlers: [
    TokenHandler('width', (post, config) => post.width.toString()),
    TokenHandler('height', (post, config) => post.height.toString()),
  ],
);
