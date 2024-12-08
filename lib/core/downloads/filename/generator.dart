// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/filename_generators/filename_generators.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/settings.dart';
import 'token_options.dart';

abstract class DownloadFilenameGenerator<T extends Post> {
  Set<String> get availableTokens;

  Map<RegExp, TextStyle> get patternMatchMap;

  List<String> getTokenOptions(String token);
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption);

  Future<String> generate(
    Settings settings,
    BooruConfig config,
    T post, {
    Map<String, String>? metadata,
    required String downloadUrl,
  });

  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfig config,
    T post, {
    Map<String, String>? metadata,
    required String downloadUrl,
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
