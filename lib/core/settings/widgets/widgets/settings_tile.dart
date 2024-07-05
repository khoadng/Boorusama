// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/widgets/option_dropdown_button.dart';

class SettingsTile<T> extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.selectedOption,
    required this.onChanged,
    this.leading,
    required this.items,
    required this.optionBuilder,
    this.padding,
  });

  final Widget title;
  final Widget? subtitle;
  final T selectedOption;
  final void Function(T item) onChanged;
  final Widget? leading;
  final List<T> items;
  final Widget Function(T item) optionBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding,
      leading: leading,
      subtitle: subtitle,
      title: title,
      trailing: OptionDropDownButton<T>(
        backgroundColor: Colors.transparent,
        alignment: AlignmentDirectional.centerEnd,
        value: selectedOption,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: items
            .map<DropdownMenuItem<T>>((value) => DropdownMenuItem<T>(
                  value: value,
                  child: optionBuilder(value),
                ))
            .toList(),
      ),
    );
  }
}
