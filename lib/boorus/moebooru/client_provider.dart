// Package imports:
import 'package:booru_clients/moebooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final moebooruClientProvider = Provider.family<MoebooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));

    return MoebooruClient.custom(
      baseUrl: config.url,
      login: config.login,
      apiKey: config.apiKey,
      dio: dio,
    );
  },
);
