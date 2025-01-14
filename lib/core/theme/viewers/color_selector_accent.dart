// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/color_utils.dart';
import '../named_colors.dart';
import '../theme_configs.dart';
import 'widgets.dart';

class AccentColorSelector extends StatefulWidget {
  const AccentColorSelector({
    required this.onSchemeChanged,
    super.key,
    this.initialScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? initialScheme;

  @override
  State<AccentColorSelector> createState() => _AccentColorSelectorState();
}

class _AccentColorSelectorState extends State<AccentColorSelector> {
  late var _settings = widget.initialScheme?.schemeType == SchemeType.accent
      ? widget.initialScheme
      : null;
  late var _currentColor = _settings?.name;
  late var _isDark = widget.initialScheme?.brightness == Brightness.dark;

  late var _variant = widget.initialScheme?.dynamicSchemeVariant ??
      DynamicSchemeVariant.tonalSpot;

  var _viewAllColor = false;

  @override
  Widget build(BuildContext context) {
    final colorWidgets = [
      ...themeAccentColors.keys.map(
        (e) {
          final color = themeAccentColors[e]!;
          final cs = ColorScheme.fromSeed(
            seedColor: color,
            brightness: _isDark ? Brightness.dark : Brightness.light,
            dynamicSchemeVariant: _variant,
          );

          final selected = _settings?.name == color.hexWithoutAlpha;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: PreviewColorContainer(
              onTap: () {
                setState(() {
                  _settings = ColorSettings.fromAccentColor(
                    color,
                    brightness: _isDark ? Brightness.dark : Brightness.light,
                    dynamicSchemeVariant: _variant,
                  );
                  _currentColor = color.hexWithoutAlpha;
                  widget.onSchemeChanged(_settings);
                });
              },
              selected: selected,
              primary: color,
              onSurface: cs.onSurface,
            ),
          );
        },
      ),
    ];

    const padding = EdgeInsets.symmetric(
      horizontal: 12,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          Container(
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      _viewAllColor = !_viewAllColor;
                    });
                  },
                  child: !_viewAllColor
                      ? const Text('Show all')
                      : const Text('Show less'),
                ),
              ],
            ),
          ),
          if (!_viewAllColor)
            SizedBox(
              height: 52,
              child: ListView(
                padding: padding,
                scrollDirection: Axis.horizontal,
                children: colorWidgets,
              ),
            )
          else
            Wrap(
              runSpacing: 4,
              children: colorWidgets,
            ),
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
          ColorVariantSelector(
            padding: padding,
            variant: _variant,
            onChanged: (value) async {
              if (value == null) return;

              setState(() {
                _settings = ColorSettings.fromAccentColor(
                  ColorUtils.hexToColor(_currentColor) ??
                      themeAccentColors.values.first,
                  brightness: _isDark ? Brightness.dark : Brightness.light,
                  dynamicSchemeVariant: value,
                );

                _variant = value;

                widget.onSchemeChanged(_settings);
              });
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: padding,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              title: const Text('Dark mode'),
              value: _isDark,
              onChanged: (value) {
                final color = ColorUtils.hexToColor(_currentColor);

                if (color == null) return;

                setState(() {
                  _isDark = value;

                  _settings = ColorSettings.fromAccentColor(
                    color,
                    brightness: value ? Brightness.dark : Brightness.light,
                    dynamicSchemeVariant: _variant,
                  );
                  widget.onSchemeChanged(_settings);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
