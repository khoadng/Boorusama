// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../posts/rating/types.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import 'create_booru_rating_options_tile.dart';

class DefaultBooruRatingOptionsTile extends ConsumerWidget {
  const DefaultBooruRatingOptionsTile({
    super.key,
    this.options,
  });

  final Set<Rating>? options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);

    return CreateBooruRatingOptionsTile(
      config: config,
      initialGranularRatingFilters: ref.watch(
        editBooruConfigProvider(
          ref.watch(editBooruConfigIdProvider),
        ).select((value) => value.granularRatingFilterTyped),
      ),
      value: ref.watch(
        editBooruConfigProvider(
          ref.watch(editBooruConfigIdProvider),
        ).select((value) => BooruConfigRatingFilter.parse(value.ratingFilter)),
      ),
      onChanged: (value) =>
          value != null ? ref.editNotifier.updateRatingFilter(value) : null,
      onGranularRatingFiltersChanged: (value) =>
          ref.editNotifier.updateGranularRatingFilter(value),
      options: options,
    );
  }
}
