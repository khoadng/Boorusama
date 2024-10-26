import 'dart:io';

import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'widgets.dart';

class ExtractImageColorSelector extends StatefulWidget {
  const ExtractImageColorSelector({
    super.key,
    required this.onSchemeChanged,
    this.initialScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? initialScheme;

  @override
  State<ExtractImageColorSelector> createState() =>
      _ExtractImageColorSelectorState();
}

class _ExtractImageColorSelectorState extends State<ExtractImageColorSelector> {
  late var _settings = widget.initialScheme;
  late var _isDark = widget.initialScheme?.brightness == Brightness.dark;
  var _imagePath = '';
  late var _variant = widget.initialScheme?.dynamicSchemeVariant ??
      DynamicSchemeVariant.tonalSpot;

  Future<void> _pickFile({
    required void Function(String path) onPick,
  }) {
    return pickSingleFilePathToastOnError(
      context: context,
      onPick: (path) {
        onPick(path);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          if (_imagePath.isNotEmpty)
            ColorVariantSelector(
              variant: _variant,
              onChanged: (value) async {
                if (value == null) return;

                await _updateScheme(
                  _imagePath,
                  value,
                  _isDark ? Brightness.dark : Brightness.light,
                );

                setState(() {
                  _variant = value;
                });
              },
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imagePath.isNotEmpty)
                DarkModeToggleButton(
                  isDark: _isDark,
                  onChanged: (value) async {
                    setState(() {
                      _isDark = value;
                    });

                    await _updateScheme(
                      _imagePath,
                      _variant,
                      value ? Brightness.dark : Brightness.light,
                    );
                  },
                ),
              if (_imagePath.isNotEmpty)
                const SizedBox(
                  width: 8,
                ),
              if (_imagePath.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: const VerticalDivider(
                    thickness: 3,
                  ),
                ),
              if (_imagePath.isNotEmpty)
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                        top: 12,
                      ),
                      child: Image.file(
                        File(_imagePath),
                        width: 120,
                        height: 120,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircularIconButton(
                        padding: const EdgeInsets.all(4),
                        icon: Icon(Symbols.edit),
                        onPressed: () {
                          _pickFile(
                            onPick: (path) async {
                              await _updateScheme(
                                path,
                                _variant,
                                _isDark ? Brightness.dark : Brightness.light,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              else if (widget.initialScheme?.colorScheme != null)
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(
                        bottom: 12,
                        top: 8,
                        right: 8,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    widget.initialScheme?.colorScheme?.primary,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: ClipPath(
                              clipper: SplashClipper(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.initialScheme?.colorScheme
                                      ?.secondaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircularIconButton(
                        padding: const EdgeInsets.all(4),
                        icon: Icon(Symbols.edit),
                        onPressed: () {
                          _pickFile(
                            onPick: (path) async {
                              await _updateScheme(
                                path,
                                _variant,
                                _isDark ? Brightness.dark : Brightness.light,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )
              else
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 24,
                    top: 24,
                  ),
                  child: _buildPickButton(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateScheme(
    String path,
    DynamicSchemeVariant variant,
    Brightness brightness,
  ) async {
    final imageProvider = FileImage(
      File(path),
    );

    final cs = await ColorScheme.fromImageProvider(
      provider: imageProvider,
      dynamicSchemeVariant: variant,
      brightness: brightness,
    );

    final settings = ColorSettings.fromImage(
      cs,
      brightness: brightness,
      dynamicSchemeVariant: variant,
    );

    setState(() {
      _imagePath = path;
      _settings = settings;
      widget.onSchemeChanged(_settings);
    });
  }

  Widget _buildPickButton(
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.secondaryContainer,
          ),
          onPressed: () {
            _pickFile(
              onPick: (path) async {
                await _updateScheme(
                  path,
                  _variant,
                  _isDark ? Brightness.dark : Brightness.light,
                );
              },
            );
          },
          child: Text(
            widget.initialScheme?.colorScheme != null
                ? 'Change image'
                : 'Pick an image',
            style: TextStyle(
              color: context.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
