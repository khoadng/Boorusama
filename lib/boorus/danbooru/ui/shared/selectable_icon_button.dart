import 'package:flutter/material.dart';

class SelectableIconButton extends StatefulWidget {
  const SelectableIconButton({
    super.key,
    required this.selectedIcon,
    required this.unSelectedIcon,
    required this.onChanged,
  });

  final Widget selectedIcon;
  final Widget unSelectedIcon;
  final void Function(bool selected) onChanged;

  @override
  State<SelectableIconButton> createState() => _SelectableIconButtonState();
}

class _SelectableIconButtonState extends State<SelectableIconButton> {
  var selected = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => setState(() {
        selected = !selected;
        widget.onChanged.call(selected);
      }),
      icon: selected ? widget.selectedIcon : widget.unSelectedIcon,
    );
  }
}
