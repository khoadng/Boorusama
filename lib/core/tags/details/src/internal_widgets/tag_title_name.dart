// Flutter imports:
import 'package:flutter/material.dart';

class TagTitleName extends StatelessWidget {
  const TagTitleName({
    required this.tagName,
    super.key,
  });

  final String tagName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        tagName.replaceAll('_', ' '),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
