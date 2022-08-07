// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsTile<T> extends StatelessWidget {
  const SettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.selectedOption,
    required this.onChanged,
    this.leading,
    required this.items,
    required this.optionBuilder,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;
  final T selectedOption;
  final void Function(T item) onChanged;
  final Widget? leading;
  final List<T> items;
  final Widget Function(T item) optionBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: leading,
        subtitle: subtitle,
        title: title,
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            alignment: AlignmentDirectional.centerEnd,
            isDense: true,
            value: selectedOption,
            focusColor: Colors.transparent,
            icon: const Padding(
                padding: EdgeInsets.only(left: 5, top: 2),
                child: FaIcon(FontAwesomeIcons.angleDown, size: 16)),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            items: items.map<DropdownMenuItem<T>>((value) {
              return DropdownMenuItem<T>(
                value: value,
                child: optionBuilder(value),
              );
            }).toList(),
          ),
        ));
    // }
  }
}
