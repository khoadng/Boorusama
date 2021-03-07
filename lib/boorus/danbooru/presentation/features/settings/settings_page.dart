// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:boorusama/generated/i18n.dart';
import 'appearance_page.dart';
import 'tag_settings_page.dart';

class SettingsPage extends HookWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifier.state).settings;
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.of(context).settings_string),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SettingsList(
          backgroundColor: Theme.of(context).appBarTheme.color,
          sections: [
            SettingsSection(
              title: I18n.of(context).settingsAppSettings_string,
              tiles: [
                SettingsTile.switchTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: I18n.of(context).settingsAppSettingsSafeMode,
                    onToggle: (value) {
                      settings.safeMode = value;
                      context.read(settingsNotifier).save(settings);
                    },
                    switchValue: settings.safeMode),
                SettingsTile(
                  leading: Icon(Icons.tag),
                  title: I18n.of(context).settingsAppSettingsBlacklistedTags,
                  onPressed: (context) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => TagSettingsPage(
                          settings: settings,
                        ),
                      ),
                    );
                  },
                ),
                //TODO: re-add theme
                // SettingsTile(
                //   leading: Icon(Icons.format_paint),
                //   title: I18n.of(context).settingsAppSettingsAppearance_string,
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (BuildContext context) => AppearancePage(
                //           settings: settings,
                //         ),
                //       ),
                //     );
                //   },
                // ),
                SettingsTile(
                  leading: Icon(Icons.translate),
                  title: I18n.of(context).settingsAppSettingsLanguage_string,
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    icon: Icon(Icons.keyboard_arrow_right),
                    onChanged: (value) {
                      settings.language = value;
                      context.read(settingsNotifier).save(settings);
                      I18n.onLocaleChanged(Locale(value));
                    },
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: "en",
                        child: Text(I18n.of(context)
                            .settingsAppSettingsLanguageEnglish),
                      ),
                      DropdownMenuItem(
                        value: "vi",
                        child: Text(I18n.of(context)
                            .settingsAppSettingsLanguageVietnamese),
                      ),
                    ],
                  ),
                  onPressed: (context) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => AppearancePage(
                          settings: settings,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
