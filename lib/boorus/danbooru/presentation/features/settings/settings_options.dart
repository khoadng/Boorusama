// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';

Future<T?> showRadioOptionsModalBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required Widget Function(T item) titleBuilder,
  required T groupValue,
  required void Function(T value) onChanged,
}) =>
    showAppModalBottomSheet(
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
