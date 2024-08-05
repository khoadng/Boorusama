// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'providers.dart';

class DanbooruHideDeletedSwitch extends ConsumerWidget {
  const DanbooruHideDeletedSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final hideDeleted = ref.watch(hideDeletedProvider(config));

    return CreateBooruHideDeletedSwitch(
      value: hideDeleted,
      onChanged: (value) =>
          ref.read(hideDeletedProvider(config).notifier).state = value,
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
    final bannedVis = ref.watch(bannedPostVisibilityProvider);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Hide banned posts'),
      value: bannedVis == BooruConfigBannedPostVisibility.hide,
      onChanged: (value) =>
          ref.read(bannedPostVisibilityProvider.notifier).state = value
              ? BooruConfigBannedPostVisibility.hide
              : BooruConfigBannedPostVisibility.show,
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
    final config = ref.watch(initialBooruConfigProvider);
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return CreateBooruImageDetailsResolutionOptionTile(
      value: imageDetailsQuality,
      items: PostQualityType.values.map((e) => e.stringify()).toList(),
      onChanged: (value) =>
          ref.read(imageDetailsQualityProvider(config).notifier).state = value,
    );
  }
}
