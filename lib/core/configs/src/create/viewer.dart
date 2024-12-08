// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'riverpod_widgets.dart';

class BooruConfigViewerView extends ConsumerWidget {
  const BooruConfigViewerView({
    super.key,
    this.postDetailsResolution,
  });

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
        ],
      ),
    );
  }
}
