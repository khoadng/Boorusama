// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final gelbooruV2ClientProvider =
    Provider.family<GelbooruV2Client, BooruConfigAuth>((ref, config) {
      final dio = ref.watch(defaultDioProvider(config));

      return GelbooruV2Client(
        baseUrl: config.url,
        userId: config.login,
        apiKey: config.apiKey,
        dio: dio,
      );
    });
