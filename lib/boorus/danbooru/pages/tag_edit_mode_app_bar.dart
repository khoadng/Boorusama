// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

class TagEditModeAppBar extends StatelessWidget {
  const TagEditModeAppBar({
    super.key,
    required this.title,
    required this.expand,
    required this.onExpandChanged,
    required this.onClosed,
  });

  final String title;
  final bool expand;
  final void Function(bool value) onExpandChanged;
  final void Function() onClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 4, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceContainerHighest,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  onExpandChanged(!expand);
                },
                child: !expand
                    ? const Icon(Symbols.arrow_drop_up)
                    : const Icon(Symbols.arrow_drop_down),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
          child: Material(
            shape: const CircleBorder(),
            color: context.colorScheme.surfaceContainerHighest,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                radius: 32,
                customBorder: const CircleBorder(),
                onTap: () {
                  onClosed();
                },
                child: const Icon(Symbols.close),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
