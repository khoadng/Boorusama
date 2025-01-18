// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../utils/color_utils.dart';
import 'color_selector_accent_notifier.dart';
import 'theme_previewer_notifier.dart';
import 'theme_widgets.dart';

class AccentColorSelector extends StatelessWidget {
  const AccentColorSelector({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          _buildColorSelectorHeader(),
          const SizedBox(height: 4),
          _buildColorSelector(),
          const SizedBox(height: 16),
          Container(
            padding: padding,
            child: const Row(
              children: [
                Text(
                  'Color Variants',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildVariantSelector(),
          const SizedBox(height: 16),
          _buildDarkThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildDarkThemeToggle() {
    return Consumer(
      builder: (_, ref, __) {
        final isDark = ref.watch(
          accentColorSelectorProvider.select((value) => value.isDark),
        );
        final notifier = ref.watch(accentColorSelectorProvider.notifier);

        return Padding(
          padding: padding,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            title: const Text('Dark mode'),
            value: isDark,
            onChanged: (value) {
              notifier.updateIsDark(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildVariantSelector() {
    return Consumer(
      builder: (_, ref, __) {
        final notifier = ref.watch(accentColorSelectorProvider.notifier);
        final variant = ref.watch(
          accentColorSelectorProvider.select((value) => value.variant),
        );

        return ColorVariantSelector(
          padding: padding,
          variant: variant,
          onChanged: (value) async {
            if (value == null) return;
            notifier.updateVariant(value);
          },
        );
      },
    );
  }

  Widget _buildColorSelectorHeader() {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Colors',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Consumer(
            builder: (_, ref, __) {
              final viewAllColor = ref.watch(
                accentColorSelectorProvider.select(
                  (value) => value.viewAllColor,
                ),
              );
              final notifier = ref.watch(accentColorSelectorProvider.notifier);

              return TextButton(
                onPressed: () {
                  notifier.toggleViewAllColor();
                },
                child: !viewAllColor
                    ? const Text('Show all')
                    : const Text('Show less'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Consumer(
      builder: (_, ref, __) {
        final viewAllColor = ref.watch(
          accentColorSelectorProvider.select(
            (value) => value.viewAllColor,
          ),
        );

        final notifier = ref.watch(accentColorSelectorProvider.notifier);

        final selectedColors = ref.watch(
          accentColorSelectorProvider.select(
            (value) => value.currentColorCode,
          ),
        );

        final themeAccentColors = ref.watch(
          themePreviewerProvider.select(
            (value) => value.accentColors,
          ),
        );

        final colorWidgets = [
          ...themeAccentColors.keys.map(
            (colorName) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                child: Builder(
                  builder: (_) {
                    final color = themeAccentColors[colorName]!;
                    final cs = notifier.getSchemeFromColor(color);
                    final selected = selectedColors == color.hexWithoutAlpha;

                    return PreviewColorContainer(
                      onTap: () {
                        notifier.updateSelectedColor(color);
                      },
                      selected: selected,
                      primary: color,
                      onSurface: cs.onSurface,
                    );
                  },
                ),
              );
            },
          ),
        ];

        return !viewAllColor
            ? SizedBox(
                height: 52,
                child: ListView(
                  padding: padding,
                  scrollDirection: Axis.horizontal,
                  children: colorWidgets,
                ),
              )
            : Padding(
                padding: padding,
                child: Wrap(
                  runSpacing: 4,
                  children: colorWidgets,
                ),
              );
      },
    );
  }
}
