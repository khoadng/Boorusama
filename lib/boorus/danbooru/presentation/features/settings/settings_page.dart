// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings_state_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'appearance_page.dart';
import 'tag_settings_page.dart';

class SettingsPage extends HookWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifier.state).settings;
    return Scaffold(
      appBar: AppBar(
        title: Text('settings._string'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SettingsList(
          backgroundColor: Theme.of(context).appBarTheme.color,
          sections: [
            SettingsSection(
              title: 'settings.appSettings._string'.tr(),
              tiles: [
                SettingsTile.switchTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: 'settings.appSettings.safeMode'.tr(),
                    onToggle: (value) {
                      settings.safeMode = value;
                      context.read(settingsNotifier).save(settings);
                    },
                    switchValue: settings.safeMode),
                SettingsTile(
                  leading: Icon(Icons.tag),
                  title: 'settings.appSettings.blacklistedTags'.tr(),
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
                //   title: settingsAppSettingsAppearance_string,
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
                  title: 'settings.appSettings.language._string'.tr(),
                  trailing: DropdownButton<String>(
                    value: settings.language,
                    icon: Icon(Icons.keyboard_arrow_right),
                    onChanged: (value) {
                      settings.language = value;
                      context.read(settingsNotifier).save(settings);
                      context.locale = Locale(value);
                    },
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: "en",
                        child: Text('settings.appSettings.language.english'.tr()),
                      ),
                      DropdownMenuItem(
                        value: "vi",
                        child: Text('settings.appSettings.language.vietnamese'.tr()),
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
            SettingsSection(
              title: "App Information",
              tiles: [
                SettingsTile(
                  title: "Acknowledgements",
                  leading: Icon(Icons.info),
                  onPressed: (context) => showAboutDialog(
                      context: context,
                      applicationIcon: Image.asset(
                        'assets/icon/icon-512x512.png',
                        width: 64,
                        height: 64,
                      ),
                      applicationVersion: "1.0.0",
                      applicationLegalese: "\u{a9} 2020-2021 Nguyen Duc Khoa",
                      applicationName: "Boorusama"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
