// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    super.key,
    required this.booruType,
  });

  final BooruType booruType;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8),
      child: Text(booruType.stringify()),
    ));
  }
}
