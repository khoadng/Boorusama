// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/appearance/types.dart';
import '../../../../configs/appearance/widgets.dart';
import '../../../../configs/config/widgets.dart';
import '../../../../foundation/platform.dart';
import '../../../../premiums/premiums.dart';
import '../../../../premiums/providers.dart';
import '../../../../theme/theme.dart';
import '../../../../theme/viewers/widgets.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/settings_provider.dart';
import '../../types/settings.dart';
import '../../types/types_l10n.dart';
import '../../widgets/settings_header.dart';
import '../../widgets/settings_interaction_blocker.dart';
import '../../widgets/settings_page_scaffold.dart';
import '../../widgets/settings_tile.dart';
import 'image_listing_settings_section.dart';

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
    final hasPremium = ref.watch(hasPremiumProvider);

    return SettingsPageScaffold(
      title: const Text('settings.appearance.appearance').tr(),
      children: [
        SettingsHeader(label: 'settings.general'.tr()),
        if (!hasPremium)
          _buildSimpleTheme(settings)
        else
          ThemeSettingsInteractionBlocker(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ThemeListTile(
                  updateMethod: ThemeUpdateMethod.applyDirectly,
                  colorSettings: settings.colors,
                  onThemeUpdated: (colors) {
                    notifier.updateSettings(
                      settings.copyWith(
                        colors: colors,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        const Divider(thickness: 1),
        SettingsHeader(label: 'settings.image_grid.image_grid'.tr()),
        ListingSettingsInteractionBlocker(
          child: ImageListingSettingsSection(
            listing: settings.listing,
            onUpdate: (value) =>
                notifier.updateSettings(settings.copyWith(listing: value)),
          ),
        ),
        const Divider(thickness: 1),
        const LayoutSection(),
        if (kPremiumEnabled)
          const BooruConfigMoreSettingsRedirectCard.appearance(),
      ],
    );
  }

  Widget _buildSimpleTheme(Settings settings) {
    final dynamicColorSupported = ref.watch(dynamicColorSupportProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

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
        if (kPremiumEnabled)
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 4,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 4,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unlock more themes with $kPremiumBrandName',
                    style: TextStyle(
                      color: colorScheme.hintColor,
                    ),
                  ).tr(),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => ThemePreviewer(
                          updateMethod: ThemeUpdateMethod.applyDirectly,
                          colorSettings: settings.colors,
                          onThemeUpdated: (colors) {
                            notifier.updateSettings(
                              settings.copyWith(colors: colors),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Preview').tr(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
