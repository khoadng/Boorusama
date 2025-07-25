// Package imports:
import 'package:filename_generator/filename_generator.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../../settings/settings.dart';
import 'token_options.dart';

abstract class DownloadFilenameGenerator<T extends Post> {
  Set<String> get availableTokens;

  List<TextMatcher> get textMatchers;

  List<String> getTokenOptions(String token);
  TokenOptionDocs? getDocsForTokenOption(String token, String tokenOption);

  Future<String> generate(
    Settings settings,
    BooruConfig config,
    T post, {
    required String downloadUrl,
    Map<String, String>? metadata,
  });

  Future<String> generateForBulkDownload(
    Settings settings,
    BooruConfig config,
    T post, {
    required String downloadUrl,
    Map<String, String>? metadata,
  });

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
