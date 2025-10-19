// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../themes/theme/types.dart';

class MobileConfigTile extends StatelessWidget {
  const MobileConfigTile({
    required this.value,
    required this.title,
    required this.onTap,
    super.key,
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
