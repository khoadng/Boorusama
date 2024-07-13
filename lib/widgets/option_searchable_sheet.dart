// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/foundation/display.dart';

class OptionSearchableSheet<T extends Object> extends StatefulWidget {
  const OptionSearchableSheet({
    super.key,
    required this.items,
    required this.onFilter,
    required this.itemBuilder,
    this.areItemsTheSame,
    this.title,
    this.scrollController,
  });

  final String? title;
  final List<T> items;
  final List<T> Function(String query) onFilter;
  final Widget Function(BuildContext context, T option) itemBuilder;
  final bool Function(T oldItem, T newItem)? areItemsTheSame;
  final ScrollController? scrollController;

  @override
  State<OptionSearchableSheet<T>> createState() =>
      _OptionSearchableSheetState();
}

class _OptionSearchableSheetState<T extends Object>
    extends State<OptionSearchableSheet<T>> {
  late var items = widget.items;
  late final scrollController = widget.scrollController ?? ScrollController();
  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              const SizedBox(height: 24),
              Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() {
                items = widget.onFilter(value);
              }),
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ImplicitlyAnimatedList<T>(
                      items: items,
                      itemBuilder: (context, animation, item, i) =>
                          widget.itemBuilder(context, item),
                      areItemsTheSame: widget.areItemsTheSame ??
                          (oldItem, newItem) => oldItem == newItem,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionSingleSearchableField<T extends Object> extends StatelessWidget {
  const OptionSingleSearchableField({
    super.key,
    this.value,
    required this.onSelect,
    required this.items,
    required this.optionValueBuilder,
    this.optionSheetValueBuilder,
    this.onTap,
    this.backgroundColor,
    this.sheetTitle,
    this.duration = const Duration(milliseconds: 300),
  });

  final T? value;
  final String? sheetTitle;
  final void Function(T? value) onSelect;
  final List<T> items;
  final String Function(T option) optionValueBuilder;
  final String Function(T option)? optionSheetValueBuilder;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () {
              showAdaptiveBottomSheet(context,
                  builder: (context) => OptionSearchableSheet<T>(
                        title: sheetTitle,
                        items: items,
                        scrollController: ModalScrollController.of(context),
                        onFilter: (query) => items.where((element) {
                          final value =
                              optionSheetValueBuilder?.call(element) ??
                                  optionValueBuilder(element);

                          return value
                              .toLowerCase()
                              .contains(query.toLowerCase());
                        }).toList(),
                        itemBuilder: (context, option) => ListTile(
                          minVerticalPadding: 4,
                          title: Text(
                            optionSheetValueBuilder?.call(option) ??
                                optionValueBuilder(option),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onSelect(option);
                          },
                        ),
                      ));
            },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                optionValueBuilder(value as T),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                FontAwesomeIcons.caretDown,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
