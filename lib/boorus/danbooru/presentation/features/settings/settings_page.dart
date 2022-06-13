// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

// Project imports:
import 'package:boorusama/app_constants.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings_state.dart';
import 'package:boorusama/main.dart';
import 'appearance_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings._string'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (previous, current) =>
              previous.settings != current.settings,
          builder: (context, state) {
            final settings = state.settings;
            return SettingsList(
              sections: [
                SettingsSection(
                  title: Text('settings.appSettings._string'.tr()),
                  tiles: [
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: Text('settings.appSettings.safeMode'.tr()),
                      onToggle: (value) {
                        context
                            .read<SettingsCubit>()
                            .update(settings.copyWith(safeMode: value));
                      },
                      initialValue: settings.safeMode,
                    ),
                    // SettingsTile(
                    //   leading: const Icon(Icons.tag),
                    //   title: Text('settings.appSettings.blacklistedTags'.tr()),
                    //   onPressed: (context) {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (BuildContext context) => TagSettingsPage(
                    //           settings: settings,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    SettingsTile(
                      leading: const Icon(Icons.translate),
                      title: Text('settings.appSettings.language._string'.tr()),
                      trailing: DropdownButton<String>(
                        value: settings.language,
                        icon: const Icon(Icons.keyboard_arrow_right),
                        onChanged: (value) {
                          if (value == null) return;
                          context
                              .read<SettingsCubit>()
                              .update(settings.copyWith(language: value));
                          context.setLocale(Locale(value));
                        },
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                                'settings.appSettings.language.english'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'vi',
                            child: Text(
                                'settings.appSettings.language.vietnamese'
                                    .tr()),
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
                  title: Text(
                      'App Information ${getVersionText(RepositoryProvider.of<PackageInfoProvider>(context).getPackageInfo())}'),
                  tiles: [
                    SettingsTile(
                      title: const Text('Acknowledgements'),
                      leading: const Icon(Icons.info),
                      onPressed: (context) => showAboutDialog(
                        context: context,
                        applicationIcon: Image.asset(
                          'assets/icon/icon-512x512.png',
                          width: 64,
                          height: 64,
                        ),
                        applicationVersion: getVersion(
                            RepositoryProvider.of<PackageInfoProvider>(context)
                                .getPackageInfo()),
                        applicationLegalese: '\u{a9} 2020-2022 Nguyen Duc Khoa',
                        applicationName: AppConstants.appName,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

String getVersion(PackageInfo info) => info.version;
String getVersionText(PackageInfo info) =>
    '(v${info.version} - Build ${info.buildNumber})';
