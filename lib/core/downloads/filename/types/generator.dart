// Package imports:
import 'package:equatable/equatable.dart';
import 'package:filename_generator/filename_generator.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../../settings/settings.dart';
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
