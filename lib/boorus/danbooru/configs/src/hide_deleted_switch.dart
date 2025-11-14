// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/configs/config/types.dart';
import '../../../../core/configs/create/providers.dart';
import '../../../../core/configs/search/widgets.dart';
import '../../../../core/configs/viewer/widgets.dart';
import '../../../../core/widgets/widgets.dart';
import '../../posts/post/types.dart';

class DanbooruHideDeletedSwitch extends ConsumerWidget {
  const DanbooruHideDeletedSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideDeleted = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider)).select(
        (value) => BooruConfigDeletedItemBehavior.parse(
          value.deletedItemBehavior,
        ).isHidden,
      ),
    );

    return CreateBooruHideDeletedSwitch(
      value: hideDeleted,
      onChanged: (value) => ref.editNotifier.updateDeletedItemBehavior(value),
      subtitle: Text(
        context.t.booru.hide_deleted_description,
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
      ).select(
        (value) =>
            BooruConfigBannedPostVisibility.parse(value.bannedPostVisibility),
      ),
    );

    return BooruSwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.t.booru.hide_banned_label),
      value: bannedVis.isHidden,
      onChanged: (value) => ref.editNotifier.updateBannedPostVisibility(value),
      subtitle: Text(
        context.t.booru.hide_banned_description,
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
