// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/edit/tag_edit_view_controller.dart';
import 'package:boorusama/core/theme.dart';
import 'tag_edit_notifier.dart';

class TagEditContainer extends ConsumerWidget {
  const TagEditContainer({
    super.key,
    required this.title,
    required this.maxHeight,
    required this.viewController,
    required this.child,
  });

  final Widget child;
  final String title;
  final double maxHeight;
  final TagEditViewController viewController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewExpanded =
        ref.watch(tagEditProvider.select((value) => value.viewExpanded));
    final height =
        viewExpanded ? max(maxHeight - kToolbarHeight - 120.0, 280.0) : 280.0;

    return Container(
      height: height,
      color: context.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          _buildAppSheetAppbar(ref, context, title),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSheetAppbar(
      WidgetRef ref, BuildContext context, String title) {
    final notifier = ref.watch(tagEditProvider.notifier);
    final viewExpanded =
        ref.watch(tagEditProvider.select((value) => value.viewExpanded));

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 4, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceContainerHighest,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  final viewExpanded = notifier.toggleViewExpanded();
                  if (!viewExpanded) {
                    viewController.setMaxSplit(context);
                  } else {
                    viewController.setDefaultSplit();
                  }
                },
                child: !viewExpanded
                    ? const Icon(Symbols.arrow_drop_up)
                    : const Icon(Symbols.arrow_drop_down),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceContainerHighest,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  notifier.setExpandMode(null);
                  viewController.setDefaultSplit();
                },
                child: const Icon(Symbols.close),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
