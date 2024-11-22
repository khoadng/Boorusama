// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/details/details.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'create.dart';

class DefaultBooruConfigLayoutView extends ConsumerWidget {
  const DefaultBooruConfigLayoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final booruBuilder = ref.watchBooruBuilder(config);
    final data = booruBuilder?.customHomeViewBuilders ?? kDefaultAltHomeView;

    return BooruConfigLayoutView(
      altHomeView: data.keys.toList(),
      decribeView: (viewKey) => data[viewKey]?.displayName ?? 'Unknown',
    );
  }
}

class BooruConfigLayoutView extends ConsumerWidget {
  const BooruConfigLayoutView({
    super.key,
    required this.altHomeView,
    required this.decribeView,
  });

  final List<CustomHomeViewKey> altHomeView;
  final String Function(CustomHomeViewKey viewKey) decribeView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final layout = ref.watch(
            editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
                .select((value) => value.layoutTyped)) ??
        LayoutConfigs.undefined();

    final uiBuilder = ref.watchBooruBuilder(config)?.postDetailsUIBuilder;
    final details = layout.details;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Home screen"),
            subtitle: const Text(
              'Change the view of the home screen',
            ),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: layout.home,
              onChanged: (value) => ref.editNotifier.updateLayout(
                layout.copyWith(home: () => value),
              ),
              items: altHomeView
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(decribeView(value)).tr(),
                      ))
                  .toList(),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: const Text("Information widgets"),
              trailing: uiBuilder != null
                  ? TextButton(
                      child: const Text('Customize'),
                      onPressed: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => CustomDetailsChooser(
                            availableParts: uiBuilder.full.keys.toList(),
                            selectedParts:
                                layout.getParsedParts()?.toList() ?? [],
                            onDone: (parts) => ref.editNotifier.updateLayout(
                              layout.copyWith(
                                details: () => convertDetailsParts(parts),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          if (uiBuilder != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Theme.of(context).colorScheme.outlineVariant,
              //   ),
              //   borderRadius: BorderRadius.circular(8),
              // ),
              child: details != null && details.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReorderableColumn(
                          onReorder: (int oldIndex, int newIndex) {
                            final newDetails = details.toList();

                            final item = newDetails.removeAt(oldIndex);
                            newDetails.insert(newIndex, item);

                            ref.editNotifier.updateLayout(
                              layout.copyWith(details: () => newDetails),
                            );
                          },
                          children: details
                              .map(
                                (e) => Container(
                                  key: ValueKey(e.name),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.drag_indicator,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .hintColor,
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

                                          ref.editNotifier.updateLayout(
                                            layout.copyWith(
                                              details: () => details
                                                  .where(
                                                      (element) => element != e)
                                                  .toList(),
                                            ),
                                          );
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
                        ),
                      ],
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        visualDensity: VisualDensity.compact,
                        title: Text('No custom widgets, use default'),
                      ),
                    ),
            ),
          if (layout.details != null && layout.details!.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(8.0),
              child: FilledButton(
                onPressed: () => ref.editNotifier.updateLayout(
                  layout.copyWith(
                    details: () => null,
                  ),
                ),
                child: const Text('Preview'),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomDetailsChooser extends StatefulWidget {
  const CustomDetailsChooser({
    super.key,
    required this.availableParts,
    required this.selectedParts,
    required this.onDone,
  });

  final List<DetailsPart> availableParts;
  final List<DetailsPart> selectedParts;
  final void Function(List<DetailsPart> parts) onDone;

  @override
  State<CustomDetailsChooser> createState() => _CustomDetailsChooserState();
}

class _CustomDetailsChooserState extends State<CustomDetailsChooser> {
  late List<DetailsPart> selectedParts = widget.selectedParts;

  void _onAdd(DetailsPart part) {
    setState(() {
      selectedParts = [...selectedParts, part];
    });
  }

  void _onRemove(DetailsPart part) {
    setState(() {
      selectedParts =
          selectedParts.where((element) => element != part).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available widgets'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              '${selectedParts.length}/${widget.availableParts.length} selected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            trailing: FilledButton(
              onPressed: selectedParts.isNotEmpty
                  ? () {
                      widget.onDone(selectedParts);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Apply'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableParts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.availableParts[index].name),
                  leading: Checkbox(
                    value: selectedParts.contains(widget.availableParts[index]),
                    onChanged: (value) {
                      if (value == true) {
                        _onAdd(widget.availableParts[index]);
                      } else {
                        _onRemove(widget.availableParts[index]);
                      }
                    },
                  ),
                  onTap: () {
                    if (selectedParts.contains(widget.availableParts[index])) {
                      _onRemove(widget.availableParts[index]);
                    } else {
                      _onAdd(widget.availableParts[index]);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
