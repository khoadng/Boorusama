// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/configs/create.dart';

class CreateGelbooruV1ConfigPage extends StatelessWidget {
  const CreateGelbooruV1ConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final String? initialTab;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      backgroundColor: backgroundColor,
      initialTab: initialTab,
    );
  }
}
