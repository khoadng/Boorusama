// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/settings/appearance_page.dart';
import 'package:boorusama/core/ui/settings/language_page.dart';
import 'package:boorusama/core/ui/settings/privacy_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Screen.of(context).size == ScreenSize.small
        ? Scaffold(
            appBar: AppBar(title: Text('settings.settings'.tr())),
            body: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SettingsSection(
                                label: 'settings.app_settings'.tr(),
                              ),
                              // ListTile(
                              //   leading: const Icon(Icons.admin_panel_settings),
                              //   title: const Text('settings.safe_mode').tr(),
                              //   trailing: Switch(
                              //       activeColor:
                              //           Theme.of(context).colorScheme.primary,
                              //       value: settings.safeMode,
                              //       onChanged: (value) {
                              //         context.read<SettingsCubit>().update(
                              //             settings.copyWith(safeMode: value));
                              //       }),
                              // ),
                              ListTile(
                                leading: const FaIcon(FontAwesomeIcons.gears),
                                title: const Text('settings.general').tr(),
                                onTap: () => goToSettingsGeneral(context, this),
                              ),
                              ListTile(
                                leading: const FaIcon(
                                  FontAwesomeIcons.paintRoller,
                                ),
                                title: const Text('settings.appearance').tr(),
                                onTap: () =>
                                    goToSettingsAppearance(context, this),
                              ),
                              ListTile(
                                title: const Text('settings.language.language')
                                    .tr(),
                                leading: const Icon(Icons.translate),
                                onTap: () =>
                                    goToSettingsLanguage(context, this),
                              ),
                              ListTile(
                                title: const Text('download.download').tr(),
                                leading:
                                    const FaIcon(FontAwesomeIcons.download),
                                onTap: () =>
                                    goToSettingsDownload(context, this),
                              ),
                              ListTile(
                                title: const Text(
                                  'settings.performance.performance',
                                ).tr(),
                                leading: const FaIcon(FontAwesomeIcons.gear),
                                onTap: () =>
                                    goToSettingsPerformance(context, this),
                              ),
                              ListTile(
                                title: const Text('settings.search').tr(),
                                leading: const FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                ),
                                onTap: () => goToSettingsSearch(context, this),
                              ),
                              ListTile(
                                title: const Text('settings.network').tr(),
                                leading: const FaIcon(
                                  FontAwesomeIcons.networkWired,
                                ),
                                onTap: () => goToSettingsNetwork(context, this),
                              ),
                              ListTile(
                                title:
                                    const Text('settings.privacy.privacy').tr(),
                                leading:
                                    const FaIcon(FontAwesomeIcons.shieldHalved),
                                onTap: () => goToSettingsPrivacy(context, this),
                              ),
                              ListTile(
                                title: const Text('settings.changelog').tr(),
                                leading: const FaIcon(
                                  FontAwesomeIcons.solidNoteSticky,
                                ),
                                onTap: () => goToChanglog(context),
                              ),
                              ListTile(
                                title: const Text('settings.information').tr(),
                                leading: const Icon(Icons.info),
                                onTap: () => goToAppAboutPage(context),
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
          )
        : const _LargeLayout();
  }
}

class _LargeLayout extends StatefulWidget {
  const _LargeLayout();

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
        elevation: 0,
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
                        _SettingsSection(
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
                                context,
                              ).getPackageInfo(),
                            ),
                            applicationLegalese:
                                '\u{a9} 2020-2022 Nguyen Duc Khoa',
                            applicationName:
                                context.read<AppInfoProvider>().appInfo.appName,
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
                                    .update(settings.copyWith(safeMode: value)),
                              ),
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
  const _Divider();

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
    this.mainAxisAlignment,
  });

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
            icon: const FaIcon(FontAwesomeIcons.squareGithub),
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.label,
  });

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
