// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class RelatedTagButton extends ConsumerWidget {
  const RelatedTagButton({
    super.key,
    this.backgroundColor,
    required this.onAdd,
    required this.onRemove,
    required this.label,
  });

  final Color? backgroundColor;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Widget label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = backgroundColor;
    final colors = color != null
        ? context.generateChipColors(
            color,
            ref.watch(settingsProvider),
          )
        : null;

    return Container(
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colors?.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: colors?.borderColor ?? Colors.transparent,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
            color: colors?.foregroundColor,
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: colors?.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 2),
              SimpleIconButton(
                icon: const Icon(
                  Symbols.add,
                  size: 20,
                ),
                onPressed: onAdd,
              ),
              const SizedBox(width: 4),
              label,
              const SizedBox(width: 4),
              SimpleIconButton(
                icon: const Icon(
                  Symbols.remove,
                  size: 20,
                ),
                onPressed: onRemove,
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
    //   child: BooruChip(
    //     color: backgroundColor,
    //     leading: SimpleIconButton(
    //       icon: const Icon(Symbols.add),
    //       onPressed: onAdd,
    //     ),
    //     label: ConstrainedBox(
    //       constraints: BoxConstraints(maxWidth: context.screenWidth * 0.5),
    //       child: label,
    //     ),
    //     trailing: SimpleIconButton(
    //       icon: const Icon(Symbols.remove),
    //       onPressed: onRemove,
    //     ),
    //   ),
    // );
  }
}
