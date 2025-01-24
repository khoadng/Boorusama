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
import '../types/custom_details.dart';
import 'available_widget_selector_sheet.dart';

class DetailsLayoutManagerPage extends ConsumerStatefulWidget {
  const DetailsLayoutManagerPage({
    required this.params,
    required this.onDone,
    super.key,
  });

  final DetailsLayoutManagerParams params;
  final void Function(List<CustomDetailsPartKey> parts) onDone;

  @override
  ConsumerState<DetailsLayoutManagerPage> createState() =>
      _DetailsLayoutManagerPageState();
}

class _DetailsLayoutManagerPageState
    extends ConsumerState<DetailsLayoutManagerPage> {
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPremium = ref.watch(hasPremiumProvider);
    final notifier = ref.watch(detailsLayoutProvider(widget.params).notifier);

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
                    params: widget.params,
                    controller: ModalScrollController.of(context),
                  );
                },
              );
            },
          ),
          BooruPopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 'reset_layout':
                  notifier.resetToDefault();
              }
            },
            itemBuilder: const {
              'reset_layout': Text('Reset to default'),
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
                      params: widget.params,
                      onDone: widget.onDone,
                    ),
                    _List(controller: controller, params: widget.params),
                  ],
                ),
              ),
            ),
            if (!hasPremium)
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
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
              ),
          ],
        ),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const _List({
    required this.controller,
    required this.params,
  });

  final ScrollController controller;
  final DetailsLayoutManagerParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.watch(detailsLayoutProvider(params).notifier);
    final details = ref.watch(
      detailsLayoutProvider(params).select((value) => value.details),
    );

    return ReorderableColumn(
      scrollController: controller,
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

class _Header extends ConsumerWidget {
  const _Header({
    required this.params,
    required this.onDone,
  });

  final DetailsLayoutManagerParams params;
  final void Function(List<CustomDetailsPartKey> parts) onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParts = ref.watch(
      detailsLayoutProvider(params).select((value) => value.selectedParts),
    );
    final availableParts = ref.watch(
      detailsLayoutProvider(params).select((value) => value.availableParts),
    );

    final hasPremium = ref.watch(hasPremiumProvider);

    return ListTile(
      title: Text(
        '${selectedParts.length}/${availableParts.length} selected',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      trailing: hasPremium
          ? FilledButton(
              onPressed: selectedParts.isNotEmpty
                  ? () {
                      onDone(convertDetailsParts(selectedParts.toList()));
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Apply'),
            )
          : null,
    );
  }
}
