// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../posts/details_manager/widgets.dart';
import '../../../../posts/details_parts/types.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';

class AppearanceDetailsPage extends ConsumerWidget {
  const AppearanceDetailsPage({
    required this.uiBuilder,
    super.key,
  });

  final PostDetailsUIBuilder uiBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout =
        ref.watch(
          editBooruConfigProvider(
            ref.watch(editBooruConfigIdProvider),
          ).select((value) => value.layoutTyped),
        ) ??
        const LayoutConfigs.undefined();

    return DetailsConfigPage(
      layout: layout,
      uiBuilder: uiBuilder,
      onLayoutUpdated: (layout) {
        ref.editNotifier.updateLayout(layout);
      },
    );
  }
}
