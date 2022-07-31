// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/app_constants.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/appearance_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/language_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/settings/privacy_page.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/widgets/parallax_slide_in_page_route.dart';
import 'package:boorusama/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Screen.of(context).size == ScreenSize.small) {
      return Scaffold(
        appBar: AppBar(
          title: Text('settings.settings'.tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final settings = state.settings;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SettingsSection(
                            label: 'settings.app_settings'.tr(),
                          ),
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings),
                            title: const Text('settings.safe_mode').tr(),
                            trailing: Switch(
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                value: settings.safeMode,
                                onChanged: (value) {
                                  context.read<SettingsCubit>().update(
                                      settings.copyWith(safeMode: value));
                                }),
                          ),
                          ListTile(
                            leading: const FaIcon(FontAwesomeIcons.paintRoller),
                            title: const Text('settings.appearance').tr(),
                            onTap: () => Navigator.of(context)
                                .push(ParallaxSlideInPageRoute(
                              enterWidget: const AppearancePage(),
                              oldWidget: this,
                            )),
                          ),
                          ListTile(
                            title:
                                const Text('settings.language.language').tr(),
                            leading: const Icon(Icons.translate),
                            onTap: () => Navigator.of(context)
                                .push(ParallaxSlideInPageRoute(
                              enterWidget: const LanguagePage(),
                              oldWidget: this,
                            )),
                          ),
                          //TODO: Files downloaded in custom location won't show up in gallery app. Re-enable this feature when a better download support for Flutter landed.
                          // ListTile(
                          //   title: const Text('Download'),
                          //   leading: const FaIcon(FontAwesomeIcons.download),
                          //   onTap: () =>
                          //       Navigator.of(context).push(ParallaxSlideInPageRoute(
                          //     enterWidget: const DownloadPage(),
                          //     oldWidget: this,
                          //   )),
                          // ),
                          ListTile(
                            title: const Text('settings.privacy.privacy').tr(),
                            leading:
                                const FaIcon(FontAwesomeIcons.shieldHalved),
                            onTap: () => Navigator.of(context)
                                .push(ParallaxSlideInPageRoute(
                              enterWidget: const PrivacyPage(),
                              oldWidget: this,
                            )),
                          ),

                          ListTile(
                            title: const Text('settings.information').tr(),
                            leading: const Icon(Icons.info),
                            onTap: () => showAboutDialog(
                              context: context,
                              applicationIcon: Image.asset(
                                'assets/icon/icon-512x512.png',
                                width: 64,
                                height: 64,
                              ),
                              applicationVersion: getVersion(
                                  RepositoryProvider.of<PackageInfoProvider>(
                                          context)
                                      .getPackageInfo()),
                              applicationLegalese:
                                  '\u{a9} 2020-2022 Nguyen Duc Khoa',
                              applicationName: AppConstants.appName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _Divider(),
                  const _Footer(),
                ],
              );
            },
          ),
        ),
      );
    } else {
      return const _LargeLayout();
    }
  }
}

class _LargeLayout extends StatefulWidget {
  const _LargeLayout({
    Key? key,
  }) : super(key: key);

  @override
  State<_LargeLayout> createState() => _LargeLayoutState();
}

//TODO: refactor this when having more settings, this is a terrible design.
class _LargeLayoutState extends State<_LargeLayout> {
  final currentTab = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text('settings.settings'.tr()),
      ),
      body:
          BlocBuilder<SettingsCubit, SettingsState>(builder: (context, state) {
        final settings = state.settings;

        return ValueListenableBuilder<int>(
          valueListenable: currentTab,
          builder: (context, index, _) => SizedBox(
            width: 800,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsSection(
                          label: 'settings.app_settings'.tr(),
                        ),
                        ListTile(
                          textColor: index == 0 ? Colors.white : null,
                          tileColor: index == 0 ? Colors.grey[800] : null,
                          title: const Text('settings.safe_mode').tr(),
                          onTap: () => currentTab.value = 0,
                        ),
                        ListTile(
                          textColor: index == 1 ? Colors.white : null,
                          tileColor: index == 1 ? Colors.grey[800] : null,
                          title: const Text('settings.appearance').tr(),
                          onTap: () => currentTab.value = 1,
                        ),
                        ListTile(
                          textColor: index == 2 ? Colors.white : null,
                          tileColor: index == 2 ? Colors.grey[800] : null,
                          title: const Text('settings.language.language').tr(),
                          onTap: () => currentTab.value = 2,
                        ),
                        ListTile(
                          textColor: index == 3 ? Colors.white : null,
                          tileColor: index == 3 ? Colors.grey[800] : null,
                          title: const Text('settings.privacy.privacy').tr(),
                          onTap: () => currentTab.value = 3,
                        ),
                        const Divider(
                          thickness: 0.8,
                          endIndent: 10,
                          indent: 10,
                        ),
                        ListTile(
                          title: const Text('settings.information').tr(),
                          onTap: () => showAboutDialog(
                            context: context,
                            applicationIcon: Image.asset(
                              'assets/icon/icon-512x512.png',
                              width: 64,
                              height: 64,
                            ),
                            applicationVersion: getVersion(
                                RepositoryProvider.of<PackageInfoProvider>(
                                        context)
                                    .getPackageInfo()),
                            applicationLegalese:
                                '\u{a9} 2020-2022 Nguyen Duc Khoa',
                            applicationName: AppConstants.appName,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: _Footer(
                            mainAxisAlignment: MainAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: index,
                    children: [
                      Scaffold(
                        body: Column(
                          children: [
                            ListTile(
                              title: const Text('Enable'),
                              trailing: Switch(
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  value: settings.safeMode,
                                  onChanged: (value) => context
                                      .read<SettingsCubit>()
                                      .update(
                                          settings.copyWith(safeMode: value))),
                            ),
                          ],
                        ),
                      ),
                      const AppearancePage(
                        hasAppBar: false,
                      ),
                      const LanguagePage(
                        hasAppBar: false,
                      ),
                      const PrivacyPage(
                        hasAppBar: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 4,
      indent: 8,
      endIndent: 8,
      thickness: 1,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    Key? key,
    this.mainAxisAlignment,
  }) : super(key: key);

  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(context.read<AppInfoProvider>().appInfo.githubUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const FaIcon(FontAwesomeIcons.githubSquare),
          ),
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(context.read<AppInfoProvider>().appInfo.discordUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const FaIcon(FontAwesomeIcons.discord),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}

String getVersion(PackageInfo info) => info.version;
String getVersionText(PackageInfo info) => info.version;
