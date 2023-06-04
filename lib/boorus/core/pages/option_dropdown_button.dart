// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionDropDownButton<T> extends StatelessWidget {
  const OptionDropDownButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
  });

  final T value;
  final void Function(T? value) onChanged;
  final List<DropdownMenuItem<T>> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isDense: true,
            value: value,
            icon: const Padding(
              padding: EdgeInsets.only(left: 5, top: 2),
              child: FaIcon(FontAwesomeIcons.angleDown, size: 16),
            ),
            onChanged: onChanged,
            items: items,
          ),
        ),
      ),
    );
  }
}
