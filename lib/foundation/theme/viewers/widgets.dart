// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

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
    super.key,
    required this.variant,
    required this.onChanged,
  });

  final DynamicSchemeVariant variant;
  final void Function(DynamicSchemeVariant? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: variant,
      onChanged: onChanged,
      items: _kVariantsOptions
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(
                switch (value) {
                  DynamicSchemeVariant.tonalSpot => 'Tonal',
                  DynamicSchemeVariant.fidelity => 'Fidelity',
                  DynamicSchemeVariant.monochrome => 'Monochrome',
                  DynamicSchemeVariant.neutral => 'Neutral',
                  DynamicSchemeVariant.vibrant => 'Vibrant',
                  DynamicSchemeVariant.expressive => 'Expressive',
                  DynamicSchemeVariant.content => 'Content',
                  DynamicSchemeVariant.rainbow => 'Rainbow',
                  DynamicSchemeVariant.fruitSalad => 'Fruit Salad',
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class DarkModeToggleButton extends StatelessWidget {
  const DarkModeToggleButton({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  final bool isDark;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      padding: const EdgeInsets.all(8),
      backgroundColor: isDark
          ? context.colorScheme.primary
          : context.colorScheme.surfaceContainerHighest,
      iconColor: isDark
          ? context.colorScheme.onPrimary
          : context.colorScheme.onSurface,
      icon: Icon(Symbols.dark_mode),
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
    final path = Path();

    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CategoryToggleSwitch extends StatelessWidget {
  const CategoryToggleSwitch({
    super.key,
    required this.onToggle,
    required this.initialCategory,
  });

  final void Function(ThemeCategory category) onToggle;
  final ThemeCategory initialCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BooruSegmentedButton(
        initialValue: initialCategory,
        segments: {
          ThemeCategory.basic: 'Basic',
          ThemeCategory.builtIn: 'Built-in',
          ThemeCategory.accent: 'Accent',
        },
        onChanged: (value) => onToggle(value),
        selectedColor: context.colorScheme.primaryContainer,
        unselectedColor: context.colorScheme.surface,
        selectedTextStyle: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
        ),
        unselectedTextStyle: TextStyle(
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class PreviewColorContainer extends StatelessWidget {
  const PreviewColorContainer({
    super.key,
    required this.primary,
    required this.onSurface,
    required this.selected,
    required this.onTap,
    this.followSystem = false,
  });

  final Color primary;
  final Color onSurface;
  final void Function() onTap;
  final bool selected;
  final bool followSystem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: followSystem ? null : primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: followSystem ? context.colorScheme.onSurface : primary,
            width: 1,
          ),
        ),
        child: selected
            ? Builder(
                builder: (context) {
                  final iconSurfaceColor =
                      followSystem ? context.colorScheme.surface : primary;

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