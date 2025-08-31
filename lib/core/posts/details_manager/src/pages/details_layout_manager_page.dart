// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import '../../../../premiums/providers.dart';
import '../../../../premiums/widgets.dart';
import '../../../../theme/app_theme.dart';
import '../../types.dart';
import '../providers/details_layout_provider.dart';
import '../routes/routes.dart';

class DetailsLayoutManagerPage extends ConsumerWidget {
  const DetailsLayoutManagerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = InheritedDetailsLayoutManagerParams.of(context);

    final notifier = ref.watch(
      detailsLayoutProvider(params).notifier,
    );

    final hasPremium = ref.watch(hasPremiumProvider);

    final canApply = ref.watch(
      detailsLayoutProvider(params).select((value) => value.canApply),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settings.appearance.customize),
        actions: [
          ElevatedButton(
            onPressed: canApply
                ? () async {
                    final navigator = Navigator.of(context);
                    final layoutPreviewState = ref.read(
                      premiumLayoutPreviewProvider,
                    );

                    final isInitiallyOff =
                        layoutPreviewState.status == LayoutPreviewStatus.off;

                    if (!hasPremium) {
                      final result = await showDialog<bool?>(
                        context: context,
                        builder: (context) => PremiumLayoutPreviewDialog(
                          firstTime: isInitiallyOff,
                          onStartPreview: () {
                            notifier.save();
                          },
                        ),
                      );

                      if (result == true) {
                        notifier.save();
                        navigator.pop();
                      }

                      return;
                    }

                    notifier.save();
                    navigator.pop();
                  }
                : null,
            child: Text(context.t.generic.action.apply),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _List(params: params),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            notifier.resetToDefault();
                          },
                          child: Text(
                            context.t.generic.action.reset,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({
    required this.params,
  });

  final DetailsLayoutManagerParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(detailsLayoutProvider(params).notifier);
    final state = ref.watch(detailsLayoutProvider(params));
    final allParts = state.allPartsInOrder;

    return ReorderableColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      header: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          context.t.booru.appearance.image_viewer_layout.rearrange_tip,
          style: TextStyle(
            color: colorScheme.hintColor,
          ),
        ),
      ),
      onReorder: (oldIndex, newIndex) {
        notifier.reorder(oldIndex, newIndex);
      },
      children: allParts.map(
        (part) {
          final isSelected = state.isSelected(part);
          return Container(
            key: ValueKey(part),
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.1,
              ),
              color: isSelected
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                Icons.drag_indicator,
                color: isSelected
                    ? colorScheme.hintColor
                    : colorScheme.hintColor.withValues(alpha: 0.5),
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  notifier.toggle(part);
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              title: Text(
                translateDetailsPart(context, part),
                style: TextStyle(
                  color: isSelected
                      ? null
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              onTap: () {
                notifier.toggle(part);
              },
            ),
          );
        },
      ).toList(),
    );
  }
}
