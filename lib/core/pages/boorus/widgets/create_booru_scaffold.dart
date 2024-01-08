// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/booru.dart';
import 'package:boorusama/flutter.dart';
import 'selected_booru_chip.dart';

class CreateBooruScaffold extends StatelessWidget {
  const CreateBooruScaffold({
    super.key,
    this.backgroundColor,
    required this.booruType,
    required this.url,
    required this.children,
    this.isUnknown = false,
  });

  final List<Widget> children;
  final Color? backgroundColor;
  final BooruType booruType;
  final String url;
  final bool isUnknown;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SelectedBooruChip(
                    booruType: booruType,
                    url: url,
                  ),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: context.navigator.pop,
                  icon: const Icon(Symbols.close),
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
