// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/utils/color_utils.dart';
import 'color_selector_accent_notifier.dart';
import 'theme_previewer_notifier.dart';
import 'theme_widgets.dart';

final _viewAllColorProvider = StateProvider.autoDispose<bool>((ref) => false);

class AccentColorSelector extends StatelessWidget {
  const AccentColorSelector({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        _buildHarmonizeToggle(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildDarkThemeToggle() {
    return Consumer(
      builder: (_, ref, _) {
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
            title: Text('Dark mode'.hc),
            value: isDark,
            onChanged: (value) {
              notifier.updateIsDark(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildHarmonizeToggle() {
    return Consumer(
      builder: (_, ref, _) {
        final harmonize = ref.watch(
          accentColorSelectorProvider.select((value) => value.harmonize),
        );
        final notifier = ref.watch(accentColorSelectorProvider.notifier);

        return Padding(
          padding: padding,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            title: Text('Harmonize colors'.hc),
            subtitle: Text(
              'Adjusts tag colors to match the accent color'.hc,
            ),
            value: harmonize,
            onChanged: (value) {
              notifier.updateHarmonize(value);
            },
          ),
        );
      },
    );
  }

  Widget _buildVariantSelector() {
    return Consumer(
      builder: (_, ref, _) {
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
          Text(
            'Colors'.hc,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Consumer(
            builder: (_, ref, _) {
              final viewAllColor = ref.watch(_viewAllColorProvider);

              return TextButton(
                onPressed: () {
                  ref.read(_viewAllColorProvider.notifier).state =
                      !viewAllColor;
                },
                child: !viewAllColor
                    ? Text('Show all'.hc)
                    : Text('Show less'.hc),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Consumer(
      builder: (_, ref, _) {
        final viewAllColor = ref.watch(_viewAllColorProvider);

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
