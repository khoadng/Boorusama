// Package imports:
import 'package:booru_clients/gelbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final gelbooruV1ClientProvider =
    Provider.family<GelbooruV1Client, BooruConfigAuth>((ref, config) {
      final dio = ref.watch(defaultDioProvider(config));

      return GelbooruV1Client(
        baseUrl: config.url,
        dio: dio,
      );
    });
