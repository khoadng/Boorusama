// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/types.dart';
import '../../../../core/configs/create/providers.dart';
import '../../../../core/configs/search/widgets.dart';
import '../../../../core/configs/viewer/widgets.dart';
import '../../posts/post/post.dart';

class DanbooruHideDeletedSwitch extends ConsumerWidget {
  const DanbooruHideDeletedSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideDeleted = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)).select(
        (value) =>
            value.deletedItemBehaviorTyped ==
            BooruConfigDeletedItemBehavior.hide,
      ),
    );

    return CreateBooruHideDeletedSwitch(
      value: hideDeleted,
      onChanged: (value) => ref.editNotifier.updateDeletedItemBehavior(value),
      subtitle: const Text(
        'Hide low-quality images, some decent ones might also be hidden.',
      ),
    );
  }
}

class DanbooruHideBannedSwitch extends ConsumerWidget {
  const DanbooruHideBannedSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannedVis = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.bannedPostVisibilityTyped),
    );

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Hide banned posts'),
      value: bannedVis == BooruConfigBannedPostVisibility.hide,
      onChanged: (value) => ref.editNotifier.updateBannedPostVisibility(value),
      subtitle: const Text(
        'Completely hide banned images from listings.',
      ),
    );
  }
}

class DanbooruImageDetailsQualityProvider extends ConsumerWidget {
  const DanbooruImageDetailsQualityProvider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageDetailsQuality = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.imageDetaisQuality),
    );

    return CreateBooruImageDetailsResolutionOptionTile(
      value: imageDetailsQuality,
      items: PostQualityType.values.map((e) => e.value).toList(),
      onChanged: (value) => ref.editNotifier.updateImageDetailsQuality(value),
    );
  }
}
