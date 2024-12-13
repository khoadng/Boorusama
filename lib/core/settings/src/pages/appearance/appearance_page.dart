// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/platform.dart';
import '../../../../theme.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/settings_provider.dart';
import '../../types/settings.dart';
import '../../types/types_l10n.dart';
import 'image_listing_settings_section.dart';
import '../../widgets/settings_header.dart';
import '../../widgets/settings_interaction_blocker.dart';
import '../../widgets/settings_page_scaffold.dart';
import '../../widgets/settings_tile.dart';

class AppearancePage extends ConsumerStatefulWidget {
  const AppearancePage({
    super.key,
  });

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);

    return SettingsPageScaffold(
      title: const Text('settings.appearance.appearance').tr(),
      children: [
        SettingsHeader(label: 'settings.general'.tr()),
        _buildSimpleTheme(settings),
        const Divider(thickness: 1),
        SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
        ListingSettingsInteractionBlocker(
          child: ImageListingSettingsSection(
            listing: settings.listing,
            onUpdate: (value) =>
                notifier.updateSettings(settings.copyWith(listing: value)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildSimpleTheme(Settings settings) {
    final dynamicColorSupported = ref.watch(dynamicColorSupportProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTile(
          title: const Text('settings.theme.theme').tr(),
          selectedOption: settings.themeMode,
          items: AppThemeMode.values,
          onChanged: (value) =>
              notifier.updateSettings(settings.copyWith(themeMode: value)),
          optionBuilder: (value) => Text(value.localize()).tr(),
        ),
        Builder(
          builder: (context) {
            return SwitchListTile(
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
              value: settings.enableDynamicColoring,
              onChanged: dynamicColorSupported
                  ? (value) => notifier.updateSettings(
                        settings.copyWith(enableDynamicColoring: value),
                      )
                  : null,
            );
          },
        ),
      ],
    );
  }
}
