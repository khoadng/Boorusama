// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/engine/providers.dart';
import '../../configs/config.dart';
import 'tag_query_composer.dart';

final tagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final composer = repo?.tagComposer(config);

    if (composer != null) {
      return composer;
    }

    return DefaultTagQueryComposer(config: config);
  },
);
