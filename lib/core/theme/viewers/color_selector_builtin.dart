// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../foundation/platform.dart';
import '../colors.dart';
import '../theme_configs.dart';
import 'widgets.dart';

class BuiltInColorSelector extends StatelessWidget {
  const BuiltInColorSelector({
    super.key,
    required this.onSchemeChanged,
    required this.currentScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? currentScheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getSchemeFromPredefined(currentScheme?.name) ??
        getSchemeFromPredefined(preDefinedColorSettings.first.name);

    if (colorScheme == null) {
      return const Center(
        child: Text('Error: Color scheme not found'),
      );
    }

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
              ...preDefinedColorSettings.map((e) {
                final selected = e.name == currentScheme?.name;
                final cs = getSchemeFromPredefined(e.name);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: PreviewColorContainer(
                    primary: cs?.primary ?? Colors.transparent,
                    onSurface: cs?.onSurface ?? colorScheme.onSurface,
                    onTap: () {
                      onSchemeChanged(e);
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

class BasicColorSelector extends ConsumerWidget {
  const BasicColorSelector({
    super.key,
    required this.onSchemeChanged,
    required this.currentScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? currentScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (light, dark) {
        final systemDarkMode =
            MediaQuery.platformBrightnessOf(context) == Brightness.dark;

        final colorScheme = getSchemeFromBasic(
              currentScheme?.name,
              dynamicLightScheme: light,
              dynamicDarkScheme: dark,
              systemDarkMode: systemDarkMode,
              enableDynamicColoring:
                  currentScheme?.enableDynamicColoring ?? false,
              followSystemDarkMode: currentScheme?.followSystemDarkMode,
            ) ??
            getSchemeFromBasic(
              basicColorSettings.first.name,
              dynamicLightScheme: light,
              dynamicDarkScheme: dark,
              systemDarkMode: systemDarkMode,
              enableDynamicColoring:
                  currentScheme?.enableDynamicColoring ?? false,
              followSystemDarkMode: currentScheme?.followSystemDarkMode,
            );

        if (colorScheme == null) {
          return const Center(
            child: Text('Error: Color scheme not found'),
          );
        }

        final enableDynamicColoring =
            currentScheme?.enableDynamicColoring ?? false;
        final dynamicColorSupported = ref.watch(dynamicColorSupportProvider);

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
                  ...basicColorSettings.map((e) {
                    final selected = e.name == currentScheme?.name;
                    final cs = getSchemeFromBasic(
                      e.name,
                      dynamicLightScheme: light,
                      dynamicDarkScheme: dark,
                      systemDarkMode: systemDarkMode,
                      enableDynamicColoring: enableDynamicColoring,
                      followSystemDarkMode: e.followSystemDarkMode,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: PreviewColorContainer(
                        followSystem: e.followSystemDarkMode == true,
                        primary: cs?.primary ?? Colors.transparent,
                        onSurface: cs?.onSurface ?? colorScheme.onSurface,
                        onTap: () {
                          onSchemeChanged(
                            e.copyWith(
                              enableDynamicColoring: enableDynamicColoring,
                            ),
                          );
                        },
                        selected: selected,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('settings.theme.dynamic_color').tr(),
                subtitle: dynamicColorSupported
                    ? !isDesktopPlatform()
                        ? const Text(
                            'settings.theme.dynamic_color_mobile_description',
                          ).tr()
                        : const Text(
                            'settings.theme.dynamic_color_desktop_description',
                          ).tr()
                    : Text(
                        '${!isDesktopPlatform() ? 'settings.theme.dynamic_color_mobile_description'.tr() : 'settings.theme.dynamic_color_desktop_description'.tr()}. ${'settings.theme.dynamic_color_unsupported_description'.tr()}',
                      ),
                value: enableDynamicColoring,
                onChanged: dynamicColorSupported
                    ? (value) => onSchemeChanged(
                          currentScheme?.copyWith(
                            enableDynamicColoring: value,
                          ),
                        )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
