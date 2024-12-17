// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../foundation/toast.dart';
import '../../../posts/details/custom_details.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';

class DetailsLayoutManagerParams extends Equatable {
  const DetailsLayoutManagerParams({
    required this.details,
    required this.availableParts,
  });

  final List<CustomDetailsPartKey> details;

  final Set<DetailsPart> availableParts;

  @override
  List<Object?> get props => [details, availableParts];
}

final detailsLayoutProvider = NotifierProvider.autoDispose.family<
    DetailsLayoutNotifier, DetailsLayoutState, DetailsLayoutManagerParams>(
  DetailsLayoutNotifier.new,
);

void goToDetailsLayoutManagerPage(
  BuildContext context, {
  required List<CustomDetailsPartKey> details,
  required Set<DetailsPart> availableParts,
  required void Function(List<CustomDetailsPartKey> parts) onDone,
}) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) {
        return DetailsLayoutManagerPage(
          params: DetailsLayoutManagerParams(
            details: details,
            availableParts: availableParts,
          ),
          onDone: onDone,
        );
      },
    ),
  );
}

class DetailsLayoutState extends Equatable {
  const DetailsLayoutState({
    required this.details,
    required this.availableParts,
  });

  final List<CustomDetailsPartKey> details;

  final Set<DetailsPart> availableParts;

  DetailsLayoutState copyWith({
    List<CustomDetailsPartKey>? details,
    Set<DetailsPart>? availableParts,
  }) {
    return DetailsLayoutState(
      details: details ?? this.details,
      availableParts: availableParts ?? this.availableParts,
    );
  }

  @override
  List<Object?> get props => [details, availableParts];
}

extension DetailsLayoutStateX on DetailsLayoutState {
  List<DetailsPart> get selectableParts {
    return availableParts.difference(selectedParts).toList();
  }

  Set<DetailsPart> get selectedParts {
    return details.map((e) => parseDetailsPart(e.name)).nonNulls.toSet();
  }
}

class DetailsLayoutNotifier extends AutoDisposeFamilyNotifier<
    DetailsLayoutState, DetailsLayoutManagerParams> {
  @override
  DetailsLayoutState build(DetailsLayoutManagerParams arg) {
    return DetailsLayoutState(
      details: arg.details,
      availableParts: arg.availableParts,
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final newDetails = state.details.toList();

    final item = newDetails.removeAt(oldIndex);
    newDetails.insert(newIndex, item);

    state = state.copyWith(
      details: newDetails,
    );
  }

  void remove(CustomDetailsPartKey key) {
    final newDetails =
        state.details.where((element) => element != key).toList();

    state = state.copyWith(
      details: newDetails,
    );
  }

  void add(DetailsPart part) {
    state = state.copyWith(
      details: [
        ...state.details,
        convertDetailsPart(part),
      ],
    );
  }
}

class DetailsLayoutManagerPage extends ConsumerStatefulWidget {
  const DetailsLayoutManagerPage({
    super.key,
    required this.params,
    required this.onDone,
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
    super.dispose();

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage details layout'),
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
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
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
    );
  }
}

class AvailableWidgetSelectorSheet extends ConsumerWidget {
  const AvailableWidgetSelectorSheet({
    super.key,
    required this.params,
    required this.controller,
  });

  final DetailsLayoutManagerParams params;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableParts = ref.watch(
      detailsLayoutProvider(params).select((value) => value.selectableParts),
    );

    final notifer = ref.watch(detailsLayoutProvider(params).notifier);

    return Scaffold(
      body: availableParts.isEmpty
          ? const Center(
              child: Text('No available widgets, all are selected'),
            )
          : ListView(
              controller: controller,
              children: availableParts
                  .map(
                    (e) => ListTile(
                      title: Text(e.name),
                      onTap: () {
                        notifer.add(e);
                        Navigator.of(context).pop(e);
                      },
                    ),
                  )
                  .toList(),
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
    final notifier = ref.watch(detailsLayoutProvider(params).notifier);
    final details = ref.watch(
      detailsLayoutProvider(params).select((value) => value.details),
    );

    return ReorderableColumn(
      scrollController: controller,
      onReorder: (int oldIndex, int newIndex) {
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
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 0.75,
                ),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.drag_indicator,
                  color: Theme.of(context).colorScheme.hintColor,
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
                  itemBuilder: {
                    'remove': const Text('Remove'),
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

    return ListTile(
      title: Text(
        '${selectedParts.length}/${availableParts.length} selected',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      trailing: FilledButton(
        onPressed: selectedParts.isNotEmpty
            ? () {
                onDone(convertDetailsParts(selectedParts.toList()));
                Navigator.of(context).pop();
              }
            : null,
        child: const Text('Apply'),
      ),
    );
  }
}
