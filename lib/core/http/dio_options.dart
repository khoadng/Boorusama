// Dart imports:
import 'dart:io';

// Project imports:
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/foundation/loggers.dart';

class DioOptions {
  DioOptions({
    required this.cacheDir,
    required this.baseUrl,
    required this.userAgent,
    required this.authConfig,
    required this.loggerService,
    required this.booruFactory,
  });
  final Directory cacheDir;
  final String baseUrl;
  final String userAgent;
  final BooruConfigAuth authConfig;
  final Logger loggerService;
  final BooruFactory booruFactory;
}
