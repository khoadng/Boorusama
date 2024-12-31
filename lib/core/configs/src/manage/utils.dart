// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../booru_config.dart';

BooruConfig? getConfigFromLink(
  BooruConfig? Function(int id) findConfigById,
  int currentConfigId,
  String? path,
) {
  final uri = path != null ? Uri.parse(path) : null;

  if (uri == null) return null;

  _print('Deep link: $uri');

  // check for '/?cid=1' format only '/settings/?cid=1' is not allowed
  final isBooruConfigDeepLink = uri.pathSegments.isEmpty;

  if (!isBooruConfigDeepLink) return null;

  _print('Deep link is booru config deep link');

  final configIdString = uri.queryParameters['cid'];
  final configId = configIdString != null ? int.tryParse(configIdString) : null;

  if (configId == null) return null;

  _print('Deep link config id: $configId');

  if (configId == currentConfigId) return null;

  _print('Deep link config id not same as current config id');

  final config = findConfigById(configId);

  if (config == null) return null;

  _print('Deep link config found: $config');

  return config;
}

void _print(String message) {
  if (!kDebugMode) return;

  print('Deeplink: $message');
}
