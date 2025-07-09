// Package imports:
import 'package:booru_clients/sankaku.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';
import 'provider.dart';

final sankakuClientProvider = Provider.family<SankakuClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));
    final booru = ref.watch(sankakuProvider);

    return SankakuClient.extended(
      dio: dio,
      baseUrl: config.url,
      username: config.login,
      password: config.apiKey,
      headers: booru.headers,
    );
  },
);
