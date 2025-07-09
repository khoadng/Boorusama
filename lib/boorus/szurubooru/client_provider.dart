// Package imports:
import 'package:booru_clients/szurubooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final szurubooruClientProvider =
    Provider.family<SzurubooruClient, BooruConfigAuth>(
      (ref, config) {
        final dio = ref.watch(dioProvider(config));

        return SzurubooruClient(
          dio: dio,
          baseUrl: config.url,
          username: config.login,
          token: config.apiKey,
        );
      },
    );
