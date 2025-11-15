// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/widgets.dart';

class SettingsTile<T> extends StatelessWidget {
  const SettingsTile({
    required this.title,
    required this.selectedOption,
    required this.onChanged,
    required this.items,
    required this.optionBuilder,
    super.key,
    this.subtitle,
    this.leading,
    this.padding,
    this.visualDensity,
  });

  final Widget title;
  final Widget? subtitle;
  final T selectedOption;
  final void Function(T item) onChanged;
  final Widget? leading;
  final List<T> items;
  final Widget Function(T item) optionBuilder;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding ?? EdgeInsets.zero,
      leading: leading,
      subtitle: subtitle,
      title: title,
      visualDensity: visualDensity,
      trailing: OptionDropDownButton<T>(
        backgroundColor: Colors.transparent,
        value: selectedOption,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: items
            .map(
              (value) => DropdownMenuItem<T>(
                value: value,
                child: optionBuilder(value),
              ),
            )
            .toList(),
      ),
    );
  }
}
