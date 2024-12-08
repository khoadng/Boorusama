// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/http/providers.dart';

final danbooruClientProvider =
    Provider.family<DanbooruClient, BooruConfigAuth>((ref, config) {
  final dio = ref.watch(dioProvider(config));

  return DanbooruClient(
    dio: dio,
    baseUrl: config.url,
    login: config.login,
    apiKey: config.apiKey,
  );
});
