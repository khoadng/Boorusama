import 'package:material_ui/material_ui.dart';

import 'option_dropdown.dart';

class KurumiSettingsTile<T> extends StatelessWidget {
  const KurumiSettingsTile({
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
    this.selectedOptionBuilder,
    this.isOptionEnabled,
    this.optionAlignment = AlignmentDirectional.centerEnd,
  });

  final Widget title;
  final Widget? subtitle;
  final T selectedOption;
  final void Function(T item) onChanged;
  final Widget? leading;
  final List<T> items;
  final Widget Function(T item) optionBuilder;
  final Widget Function(T item)? selectedOptionBuilder;
  final bool Function(T item)? isOptionEnabled;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final AlignmentDirectional optionAlignment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: padding ?? EdgeInsets.zero,
      leading: leading,
      subtitle: subtitle,
      title: title,
      visualDensity: visualDensity,
      trailing: KurumiOptionDropDownButton<T>(
        alignment: optionAlignment,
        backgroundColor: Colors.transparent,
        value: selectedOption,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        selectedItemBuilder: selectedOptionBuilder,
        items: items
            .map(
              (value) => DropdownMenuItem<T>(
                value: value,
                enabled: isOptionEnabled?.call(value) ?? true,
                child: optionBuilder(value),
              ),
            )
            .toList(),
      ),
    );
  }
}
