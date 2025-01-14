// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../widgets/widgets.dart';

// Project imports:

const _kVariantsOptions = [
  DynamicSchemeVariant.tonalSpot,
  DynamicSchemeVariant.fidelity,
  DynamicSchemeVariant.vibrant,
  DynamicSchemeVariant.expressive,
  DynamicSchemeVariant.fruitSalad,
  DynamicSchemeVariant.rainbow,
];

class ColorVariantSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ChoiceOptionSelectorList(
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
    );
  }
}

class DarkModeToggleButton extends StatelessWidget {
  const DarkModeToggleButton({
    required this.isDark,
    required this.onChanged,
    super.key,
  });

  final bool isDark;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircularIconButton(
      padding: const EdgeInsets.all(8),
      backgroundColor:
          isDark ? colorScheme.primary : colorScheme.surfaceContainerHighest,
      iconColor: isDark ? colorScheme.onPrimary : colorScheme.onSurface,
      icon: const Icon(Symbols.dark_mode),
      onPressed: () {
        onChanged(!isDark);
      },
    );
  }
}

enum ThemeCategory {
  basic,
  builtIn,
  accent,
}

class SplashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    required this.onToggle,
    required this.initialCategory,
    super.key,
  });

  final void Function(ThemeCategory category) onToggle;
  final ThemeCategory initialCategory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: BooruSegmentedButton(
        initialValue: initialCategory,
        segments: const {
          ThemeCategory.basic: 'Basic',
          ThemeCategory.builtIn: 'Built-in',
          ThemeCategory.accent: 'Accent',
        },
        onChanged: (value) => onToggle(value),
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
                  final iconSurfaceColor =
                      followSystem ? colorScheme.surface : primary;

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
