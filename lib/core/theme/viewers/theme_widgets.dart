// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../widgets/widgets.dart';
import '../providers.dart';
import '../utils.dart';
import 'theme_previewer_notifier.dart';

const _kVariantsOptions = [
  DynamicSchemeVariant.tonalSpot,
  DynamicSchemeVariant.fidelity,
  DynamicSchemeVariant.vibrant,
  DynamicSchemeVariant.expressive,
  DynamicSchemeVariant.fruitSalad,
  DynamicSchemeVariant.rainbow,
];

class ColorVariantSelector extends ConsumerWidget {
  const ColorVariantSelector({
    required this.variant,
    required this.onChanged,
    super.key,
    this.padding,
  });

  final DynamicSchemeVariant variant;
  final void Function(DynamicSchemeVariant? value) onChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(themePreviewerSchemeProvider);

    return ProviderScope(
      overrides: [
        booruChipColorsProvider.overrideWithValue(
          BooruChipColors.colorScheme(
            colorScheme,
            harmonizeWithPrimary: ref.watch(
              themePreviewerProvider.select(
                (value) => value.colors.harmonizeWithPrimary,
              ),
            ),
          ),
        ),
      ],
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: colorScheme,
        ),
        child: ChoiceOptionSelectorList(
          searchable: false,
          options: _kVariantsOptions,
          selectedOption: variant,
          onSelected: onChanged,
          hasNullOption: false,
          padding: padding,
          optionLabelBuilder: (value) => switch (value) {
            DynamicSchemeVariant.tonalSpot => 'Tonal',
            DynamicSchemeVariant.fidelity => 'Fidelity',
            DynamicSchemeVariant.monochrome => 'Monochrome',
            DynamicSchemeVariant.neutral => 'Neutral',
            DynamicSchemeVariant.vibrant => 'Vibrant',
            DynamicSchemeVariant.expressive => 'Expressive',
            DynamicSchemeVariant.content => 'Content',
            DynamicSchemeVariant.rainbow => 'Rainbow',
            DynamicSchemeVariant.fruitSalad => 'Fruit Salad',
            _ => 'Unknown',
          },
        ),
      ),
    );
  }
}

enum ThemeCategory {
  basic,
  builtIn,
  accent,
}

class ThemeCategoryToggleSwitch extends ConsumerWidget {
  const ThemeCategoryToggleSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(themePreviewerProvider.notifier);
    final colorScheme = ref.watch(themePreviewerSchemeProvider);
    final initialCategory = ref.watch(
      themePreviewerProvider.select(
        (value) => value.category,
      ),
    );

    return Center(
      child: BooruSegmentedButton(
        initialValue: initialCategory,
        segments: const {
          ThemeCategory.basic: 'Basic',
          ThemeCategory.builtIn: 'Built-in',
          ThemeCategory.accent: 'Accent',
        },
        onChanged: (value) => notifier.updateCategory(value),
        selectedColor: colorScheme.primaryContainer,
        unselectedColor: colorScheme.surface,
        selectedTextStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
        ),
        unselectedTextStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class PreviewColorContainer extends StatelessWidget {
  const PreviewColorContainer({
    required this.primary,
    required this.onSurface,
    required this.selected,
    required this.onTap,
    super.key,
    this.followSystem = false,
  });

  final Color primary;
  final Color onSurface;
  final void Function() onTap;
  final bool selected;
  final bool followSystem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: followSystem ? null : primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: followSystem ? colorScheme.onSurface : primary,
            width: 1,
          ),
        ),
        child: selected
            ? Builder(
                builder: (context) {
                  final iconSurfaceColor = followSystem
                      ? colorScheme.surface
                      : primary;

                  return Icon(
                    Icons.check,
                    color: iconSurfaceColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: 36,
                  );
                },
              )
            : null,
      ),
    );
  }
}
