// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_hide_deleted_switch.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
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
