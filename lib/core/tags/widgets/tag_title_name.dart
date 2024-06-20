// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';

class TagTitleName extends StatelessWidget {
  const TagTitleName({
    super.key,
    required this.tagName,
  });

  final String tagName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        tagName.replaceUnderscoreWithSpace(),
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
