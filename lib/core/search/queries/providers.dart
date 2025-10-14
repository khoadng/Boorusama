// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config/types.dart';
import 'tag_query_composer.dart';

final tagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final composer = repo?.tagComposer(config);

        if (composer != null) {
          return composer;
        }

        return ref.watch(defaultTagQueryComposerProvider(config));
      },
    );

final defaultTagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) => DefaultTagQueryComposer(config: config),
    );

final legacyTagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) => LegacyTagQueryComposer(config: config),
    );
