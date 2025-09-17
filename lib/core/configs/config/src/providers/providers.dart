// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../settings/providers.dart';
import '../../../manage/providers.dart';
import '../types/booru_config.dart';

final hasBooruConfigsProvider = Provider<bool>((ref) {
  final configs = ref.watch(booruConfigProvider);
  return configs.isNotEmpty;
});

final orderedConfigsProvider = FutureProvider.autoDispose<IList<BooruConfig>>((
  ref,
) {
  final configs = ref.watch(booruConfigProvider);

  final configMap = {for (final config in configs) config.id: config};
  final orders = ref.watch(
    settingsProvider.select((value) => value.booruConfigIdOrderList),
  );

  if (configMap.length != orders.length) {
    return configMap.values.toIList();
  }

  try {
    return orders.map((e) => configMap[e]!).toIList();
  } catch (e) {
    return configMap.values.toIList();
  }
});

final firstMatchingConfigProvider =
    Provider.family<BooruConfig?, (int, String)>(
      (ref, params) {
        final (id, url) = params;
        final configs = ref.watch(booruConfigProvider);
        final idResult = configs
            .where(
              (config) => config.auth.booruIdHint == id || config.booruId == id,
            )
            .toList();

        if (idResult.isEmpty) {
          return null;
        }

        final config = idResult.firstWhereOrNull((config) {
          final authUrl = config.auth.url.endsWith('/')
              ? config.auth.url.substring(0, config.auth.url.length - 1)
              : config.auth.url;

          return url.contains(authUrl);
        });

        return config ?? idResult.firstOrNull;
      },
    );

final booruLoginDetailsProvider =
    Provider.family<BooruLoginDetails, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final loginDetails = repo?.loginDetails(config);

        if (loginDetails != null) {
          return loginDetails;
        }

        return DefaultBooruLoginDetails(
          login: config.login,
          apiKey: config.apiKey,
          url: config.url,
        );
      },
    );

final defaultLoginDetailsProvider =
    Provider.family<BooruLoginDetails, BooruConfigAuth>(
      (ref, config) {
        return DefaultBooruLoginDetails(
          login: config.login,
          apiKey: config.apiKey,
          url: config.url,
        );
      },
    );
