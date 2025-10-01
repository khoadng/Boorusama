// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../providers/tag_edit_notifier.dart';
import '../tag_edit_view_controller.dart';

class TagEditContainer extends ConsumerWidget {
  const TagEditContainer({
    required this.title,
    required this.maxHeight,
    required this.viewController,
    required this.child,
    super.key,
  });

  final Widget child;
  final String title;
  final double maxHeight;
  final TagEditViewController viewController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = TagEditParamsProvider.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final viewExpanded = ref.watch(
      tagEditProvider(params).select((value) => value.viewExpanded),
    );
    final height = viewExpanded
        ? max(maxHeight - kToolbarHeight - 120.0, 280)
        : 280.0;
    final notifier = ref.watch(tagEditProvider(params).notifier);

    return Container(
      height: height.toDouble(),
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                _CircularButton(
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
                const SizedBox(width: 8),
                _CircularButton(
                  onTap: () {
                    notifier.setExpandMode(null);
                    viewController.setDefaultSplit();
                  },
                  child: const Icon(Symbols.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  const _CircularButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      shape: const CircleBorder(),
      color: colorScheme.surfaceContainerHighest,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          radius: 32,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
