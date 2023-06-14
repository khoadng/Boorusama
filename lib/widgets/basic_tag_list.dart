// Flutter imports:
import 'package:flutter/material.dart';

class BasicTagList extends StatelessWidget {
  const BasicTagList({
    Key? key,
    required this.tags,
    required this.onTap,
  }) : super(key: key);

  final List<String> tags;
  final void Function(String tag) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: tags.map((tag) {
        return RawChip(
          onPressed: () => onTap(tag),
          label: Text(tag.replaceAll('_', ' ')),
        );
      }).toList(),
    );
  }
}
