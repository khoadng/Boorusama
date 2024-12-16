// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/color_utils.dart';
import '../named_colors.dart';
import '../theme_configs.dart';
import 'widgets.dart';

class AccentColorSelector extends StatefulWidget {
  const AccentColorSelector({
    super.key,
    required this.onSchemeChanged,
    this.initialScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? initialScheme;

  @override
  State<AccentColorSelector> createState() => _AccentColorSelectorState();
}

class _AccentColorSelectorState extends State<AccentColorSelector> {
  late var _settings = widget.initialScheme;
  late var _currentColor = _settings?.name;
  late var _isDark = widget.initialScheme?.brightness == Brightness.dark;

  late var _variant = widget.initialScheme?.dynamicSchemeVariant ??
      DynamicSchemeVariant.tonalSpot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              DarkModeToggleButton(
                isDark: _isDark,
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
              const SizedBox(
                width: 6,
              ),
              const SizedBox(
                height: 28,
                child: VerticalDivider(
                  thickness: 2,
                ),
              ),
              ColorVariantSelector(
                variant: _variant,
                onChanged: (value) async {
                  if (value == null) return;
                  if (_currentColor == null) return;

                  setState(() {
                    _settings = ColorSettings.fromAccentColor(
                      ColorUtils.hexToColor(_currentColor)!,
                      brightness: _isDark ? Brightness.dark : Brightness.light,
                      dynamicSchemeVariant: value,
                    );

                    _variant = value;

                    widget.onSchemeChanged(_settings);
                  });
                },
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Row(
            children: [
              Text(
                'Default',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 12,
            ),
            child: Wrap(
              runSpacing: 8,
              children: [
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
                              brightness:
                                  _isDark ? Brightness.dark : Brightness.light,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
