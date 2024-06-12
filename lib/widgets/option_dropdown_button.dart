// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

class OptionDropDownButton<T> extends StatelessWidget {
  const OptionDropDownButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.alignment = AlignmentDirectional.centerEnd,
    this.backgroundColor,
  });

  final T value;
  final void Function(T? value) onChanged;
  final List<DropdownMenuItem<T>> items;
  final AlignmentDirectional alignment;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant,
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
          alignment: alignment,
          isDense: true,
          value: value,
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          icon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Symbols.keyboard_arrow_down,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}
