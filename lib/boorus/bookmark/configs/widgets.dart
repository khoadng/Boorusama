// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/configs/create/widgets.dart';
import '../../../core/configs/search/widgets.dart';
import '../../../core/configs/viewer/widgets.dart';

class CreateBookmarkConfigPage extends StatelessWidget {
  const CreateBookmarkConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      searchTab: const DefaultBooruConfigSearchView(),
      imageViewerTab: const BooruConfigViewerView(),
    );
  }
}
