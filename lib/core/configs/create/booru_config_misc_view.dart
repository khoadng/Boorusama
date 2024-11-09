// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/create/create.dart';

class BooruConfigMiscView extends ConsumerWidget {
  const BooruConfigMiscView({
    super.key,
    this.miscOptions,
    this.postDetailsResolution,
  });

  final List<Widget>? miscOptions;
  final Widget? postDetailsResolution;

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
          if (miscOptions != null) ...miscOptions!,
        ],
      ),
    );
  }
}
