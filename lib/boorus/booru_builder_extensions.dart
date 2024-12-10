// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../core/configs/config.dart';
import '../core/configs/ref.dart';
import 'booru_builder.dart';

extension BooruBuilderFeatureCheck on BooruBuilder {
  bool get isArtistSupported => artistPageBuilder != null;
}

extension BooruRef on Ref {
  BooruBuilder? readBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc() : null;
  }
}

extension BooruWidgetRef on WidgetRef {
  BooruBuilder? readBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilders = read(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc() : null;
  }

  BooruBuilder? watchBooruBuilder(BooruConfigAuth? config) {
    if (config == null) return null;

    final booruBuilders = watch(booruBuildersProvider);
    final booruBuilderFunc = booruBuilders[config.booruType];

    return booruBuilderFunc != null ? booruBuilderFunc() : null;
  }
}

final currentBooruBuilderProvider = Provider<BooruBuilder?>((ref) {
  final config = ref.watchConfigAuth;
  final booruBuilders = ref.watch(booruBuildersProvider);
  final booruBuilderFunc = booruBuilders[config.booruType];

  return booruBuilderFunc != null ? booruBuilderFunc() : null;
});
