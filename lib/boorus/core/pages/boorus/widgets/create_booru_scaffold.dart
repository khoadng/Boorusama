// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/booru.dart';
import 'package:boorusama/flutter.dart';
import 'selected_booru_chip.dart';

class CreateBooruScaffold extends StatelessWidget {
  const CreateBooruScaffold({
    super.key,
    this.backgroundColor,
    required this.booru,
    required this.children,
  });

  final List<Widget> children;
  final Booru booru;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SelectedBooruChip(
                  booru: booru,
                ),
                const Spacer(),
                IconButton(
                  splashRadius: 20,
                  onPressed: context.navigator.pop,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
