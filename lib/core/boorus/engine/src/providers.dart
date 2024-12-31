// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import '../../booru/booru.dart';
import 'booru_builder.dart';
import 'booru_engine.dart';

final booruEngineRegistryProvider = Provider<BooruEngineRegistry>((ref) {
  throw UnimplementedError();
});

final currentBooruProvider = Provider.family<Booru?, BooruConfigAuth>(
  (ref, config) {
    final registry = ref.watch(booruEngineRegistryProvider);

    return registry.getEngine(config.booruType)?.booru;
  },
  dependencies: [booruEngineRegistryProvider],
);

extension BooruRef on Ref {
  BooruBuilder? readBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilder =
        read(booruEngineRegistryProvider).getBuilder(config.booruType);

    return booruBuilder;
  }
}

extension BooruWidgetRef on WidgetRef {
  BooruBuilder? readBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilder =
        read(booruEngineRegistryProvider).getBuilder(config.booruType);

    return booruBuilder;
  }

  BooruBuilder? watchBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilder =
        watch(booruEngineRegistryProvider).getBuilder(config.booruType);

    return booruBuilder;
  }
}

final currentBooruBuilderProvider = Provider<BooruBuilder?>(
  (ref) {
    final config = ref.watchConfigAuth;
    final booruBuilder =
        ref.watch(booruEngineRegistryProvider).getBuilder(config.booruType);

    return booruBuilder;
  },
  dependencies: [booruEngineRegistryProvider],
);
