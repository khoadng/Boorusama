// Package imports:
import 'package:booru_clients/philomena.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';

final philomenaClientProvider =
    Provider.family<PhilomenaClient, BooruConfigAuth>(
      (ref, config) {
        final dio = ref.watch(dioProvider(config));

        return PhilomenaClient(
          dio: dio,
          baseUrl: config.url,
          apiKey: config.apiKey,
        );
      },
    );
