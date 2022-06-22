// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<T?> showOptionsModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) =>
    showMaterialModalBottomSheet(
      duration: const Duration(milliseconds: 200),
      backgroundColor: Theme.of(context).backgroundColor,
      context: context,
      builder: builder,
    );

Future<T?> showRadioOptionsModalBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required Widget Function(T item) titleBuilder,
  required T groupValue,
  required void Function(T value) onChanged,
}) =>
    showOptionsModalBottomSheet(
      context: context,
      builder: (context) => SettingsOptions<T>.radio(
        items: items,
        titleBuilder: titleBuilder,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );

class SettingsOptions<T> extends StatelessWidget {
  const SettingsOptions({
    Key? key,
    required this.items,
    required this.itemBuilder,
  }) : super(key: key);

  factory SettingsOptions.radio({
    required List<T> items,
    required Widget Function(T item) titleBuilder,
    required T groupValue,
    required void Function(T value) onChanged,
  }) =>
      SettingsOptions<T>(
        items: items,
        itemBuilder: (context, item) => RadioListTile<T>(
          value: item,
          activeColor: Theme.of(context).colorScheme.primary,
          title: titleBuilder(item),
          groupValue: groupValue,
          onChanged: (value) {
            if (value == null) return;
            Navigator.of(context).pop();
            onChanged(value);
          },
        ),
      );

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((e) => itemBuilder(context, e)).toList(),
    );
  }
}
