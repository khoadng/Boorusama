// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/theme.dart';

class MobileConfigTile extends StatelessWidget {
  const MobileConfigTile({
    super.key,
    required this.value,
    required this.title,
    required this.onTap,
  });

  final String title;
  final String value;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
      ),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.hintColor,
                fontSize: 14,
              ),
            ),
            const Icon(Symbols.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
