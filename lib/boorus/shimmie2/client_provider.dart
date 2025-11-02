// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final shimmie2ClientProvider = Provider.family<Shimmie2Client, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(defaultDioProvider(config));

    return Shimmie2Client(
      dio: dio,
      baseUrl: config.url,
      apiKey: config.apiKey,
      username: config.login,
    );
  },
);
