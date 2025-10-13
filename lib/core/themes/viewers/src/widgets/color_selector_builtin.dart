// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/types.dart';
import '../providers/theme_previewer_notifier.dart';
import 'theme_widgets.dart';

class BuiltInColorSelector extends ConsumerWidget {
  const BuiltInColorSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(themePreviewerProvider.notifier);
    final builtinColors = ref.watch(
      themePreviewerProvider.select(
        (value) => value.builtinColors,
      ),
    );
    final currentColors = ref.watch(themePreviewerColorsProvider);
    final colorScheme = ref.watch(themePreviewerSchemeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Wrap(
            runSpacing: 8,
            children: [
              ...builtinColors.map((settings) {
                final selected = settings.name == currentColors.name;
                final cs = getSchemeFromPredefined(settings.name);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: PreviewColorContainer(
                    primary: cs?.primary ?? Colors.transparent,
                    onSurface: cs?.onSurface ?? colorScheme.onSurface,
                    onTap: () {
                      notifier.updateColors(settings);
                    },
                    selected: selected,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
