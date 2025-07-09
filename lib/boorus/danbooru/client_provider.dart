// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config.dart';
import '../../core/http/providers.dart';

final danbooruClientProvider = Provider.family<DanbooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));

    return DanbooruClient(
      dio: dio,
      baseUrl: config.url,
      login: config.login,
      apiKey: config.apiKey,
    );
  },
);
