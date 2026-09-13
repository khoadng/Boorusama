// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../../../../configs/appearance/types.dart';
import '../../../../configs/appearance/widgets.dart';
import '../../../../configs/config/widgets.dart';
import '../../../../premiums/providers.dart';
import '../../../../premiums/types.dart';
import '../../../../themes/colors/providers.dart';
import '../../../../themes/theme/types.dart';
import '../../../../themes/viewers/widgets.dart';
import '../../generated/settings_index.g.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/settings_provider.dart';
import '../../types/settings.dart';
import '../../widgets/setting_anchor.dart';
import '../../widgets/settings_interaction_blocker.dart';
import '../../widgets/settings_page_scaffold.dart';
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
      title: Text(context.t.settings.appearance.appearance),
      children: [
        KurumiSettingsHeader(label: context.t.settings.general),
        if (!hasPremium)
          _buildSimpleTheme(settings)
        else
          ThemeSettingsInteractionBlocker(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingAnchor(
                  id: SettingsIndex.appearance.colors.id,
                  child: ThemeListTile(
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
                ),
              ],
            ),
          ),
        const Divider(thickness: 1),
        KurumiSettingsHeader(label: context.t.settings.image_grid.image_grid),
        ListingSettingsInteractionBlocker(
          child: ImageListingSettingsSection(
            listing: settings.listing,
            onUpdate: (value) =>
                notifier.updateSettings(settings.copyWith(listing: value)),
          ),
        ),
        const Divider(thickness: 1),
        const LayoutSection(),
        if (ref.watch(showPremiumFeatsProvider))
          const BooruConfigMoreSettingsRedirectCard.appearance(),
      ],
    );
  }

  Widget _buildSimpleTheme(Settings settings) {
    final dynamicColorSupported = ref.watch(dynamicColorSupportProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);
    final colorScheme = Kurumi.themeOf(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingAnchor(
          id: SettingsIndex.appearance.theme.id,
          child: KurumiSettingsTile(
            title: Text(SettingsIndex.appearance.theme.title(context)),
            selectedOption: settings.themeMode,
            items: KurumiThemeMode.values,
            onChanged: (value) =>
                notifier.updateSettings(settings.copyWith(themeMode: value)),
            optionBuilder: (value) => Text(value.localize(context)),
          ),
        ),
        Builder(
          builder: (context) {
            return SettingAnchor(
              id: SettingsIndex.appearance.dynamicColor.id,
              child: KurumiSwitchListTile(
                title: Text(
                  SettingsIndex.appearance.dynamicColor.title(
                    context,
                  ),
                ),
                subtitle: dynamicColorSupported
                    ? !isDesktopPlatform()
                          ? Text(
                              context
                                  .t
                                  .settings
                                  .theme
                                  .dynamic_color_mobile_description,
                            )
                          : Text(
                              context
                                  .t
                                  .settings
                                  .theme
                                  .dynamic_color_desktop_description,
                            )
                    : Text(
                        '${!isDesktopPlatform() ? context.t.settings.theme.dynamic_color_mobile_description : context.t.settings.theme.dynamic_color_desktop_description}. ${context.t.settings.theme.dynamic_color_unsupported_description}',
                      ),
                value: settings.enableDynamicColoring,
                onChanged: dynamicColorSupported
                    ? (value) => notifier.updateSettings(
                        settings.copyWith(enableDynamicColoring: value),
                      )
                    : null,
              ),
            );
          },
        ),
        if (ref.watch(showPremiumFeatsProvider))
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
                    context.t.premium.unlock_more_theme_with_premium(
                      brand: kPremiumBrandName,
                    ),
                    style: TextStyle(
                      color: colorScheme.hintColor,
                    ),
                  ),
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
                  child: Text(context.t.generic.action.view),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
