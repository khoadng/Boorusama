// Package imports:
import 'package:booru_clients/hybooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/client/providers.dart';

final hybooruClientProvider = Provider.family<HybooruClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));

    return HybooruClient(
      dio: dio,
      baseUrl: config.url,
    );
  },
);
