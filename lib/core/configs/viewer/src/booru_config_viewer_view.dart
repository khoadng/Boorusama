// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../create/providers.dart';
import 'create_booru_image_details_resolution_option_tile.dart';

class BooruConfigViewerView extends ConsumerWidget {
  const BooruConfigViewerView({
    super.key,
    this.postDetailsResolution,
    this.autoLoadNotes,
  });

  final Widget? postDetailsResolution;
  final Widget? autoLoadNotes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (postDetailsResolution != null)
            postDetailsResolution!
          else
            const DefaultImageDetailsQualityTile(),
          if (autoLoadNotes != null) autoLoadNotes!,
        ],
      ),
    );
  }
}

class DefaultImageDetailsQualityTile extends ConsumerWidget {
  const DefaultImageDetailsQualityTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruGeneralPostDetailsResolutionOptionTile(
      value: ref.watch(
        editBooruConfigProvider(
          ref.watch(editBooruConfigIdProvider),
        ).select((value) => value.imageDetaisQuality),
      ),
      onChanged: (value) => ref.editNotifier.updateImageDetailsQuality(value),
    );
  }
}
