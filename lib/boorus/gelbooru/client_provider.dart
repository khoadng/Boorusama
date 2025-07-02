// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final gelbooruClientProvider =
    Provider.family<GelbooruClient, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return GelbooruClient.custom(
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
    passHash: config.passHash,
    dio: dio,
  );
});
