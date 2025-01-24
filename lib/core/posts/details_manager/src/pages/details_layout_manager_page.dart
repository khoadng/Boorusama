// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../../premiums/providers.dart';
import '../../../../premiums/routes.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/widgets.dart';
import '../providers/details_layout_provider.dart';
import '../routes/routes.dart';
import 'available_widget_selector_sheet.dart';

class DetailsLayoutManagerPage extends StatelessWidget {
  const DetailsLayoutManagerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final params = InheritedDetailsLayoutManagerParams.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage widgets'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () {
              showBarModalBottomSheet(
                context: context,
                builder: (context) {
                  return AvailableWidgetSelectorSheet(
                    params: params,
                    controller: ModalScrollController.of(context),
                  );
                },
              );
            },
          ),
          Consumer(
            builder: (_, ref, __) {
              final notifier =
                  ref.watch(detailsLayoutProvider(params).notifier);

              return BooruPopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 'reset_layout':
                      notifier.resetToDefault();
                  }
                },
                itemBuilder: const {
                  'reset_layout': Text('Reset to default'),
                },
              );
            },
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
                    _Header(
                      params: params,
                    ),
                    _List(params: params),
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (_, ref, __) {
                final hasPremium = ref.watch(hasPremiumProvider);

                return !hasPremium
                    ? SafeArea(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 48),
                            ),
                            onPressed: () {
                              goToPremiumPage(context);
                            },
                            child: const Text('Upgrade to save'),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
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
    final details = ref.watch(
      detailsLayoutProvider(params).select((value) => value.details),
    );

    return ReorderableColumn(
      onReorder: (oldIndex, newIndex) {
        notifier.reorder(oldIndex, newIndex);
      },
      children: details
          .map(
            (e) => Container(
              key: ValueKey(e),
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
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.drag_indicator,
                  color: colorScheme.hintColor,
                ),
                trailing: BooruPopupMenuButton(
                  onSelected: (value) {
                    if (value == 'remove') {
                      if (details.length == 1) {
                        showErrorToast(
                          context,
                          'At least one item is required',
                        );
                        return;
                      }

                      notifier.remove(e);
                    }
                  },
                  itemBuilder: const {
                    'remove': Text('Remove'),
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                title: Text(e.name),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.params,
  });

  final DetailsLayoutManagerParams params;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Consumer(
        builder: (_, ref, __) {
          final (selected, available) = ref.watch(
            detailsLayoutProvider(params)
                .select((value) => value.selectedPartsCount),
          );

          return Text(
            '$selected/$available selected',
            style: Theme.of(context).textTheme.titleLarge,
          );
        },
      ),
      trailing: Consumer(
        builder: (_, ref, __) {
          final hasPremium = ref.watch(hasPremiumProvider);

          final canApply = ref.watch(
            detailsLayoutProvider(params).select((value) => value.canApply),
          );

          final notifier = ref.watch(detailsLayoutProvider(params).notifier);

          return hasPremium
              ? FilledButton(
                  onPressed: canApply
                      ? () {
                          notifier.save();
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Apply'),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
