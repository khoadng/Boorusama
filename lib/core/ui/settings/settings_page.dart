// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/infra/infra.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/settings/about_page.dart';
import 'package:boorusama/core/ui/settings/appearance_page.dart';
import 'package:boorusama/core/ui/settings/debug_logs_page.dart';
import 'package:boorusama/core/ui/settings/language_page.dart';
import 'package:boorusama/core/ui/settings/privacy_page.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    ref.watch(settingsProvider.select((value) => value.language));

    return Screen.of(context).size == ScreenSize.small
        ? Scaffold(
            appBar: AppBar(title: Text('settings.settings'.tr())),
            body: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
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
                          // ListTile(
                          //   leading: const FaIcon(FontAwesomeIcons.gears),
                          //   title: const Text('settings.general').tr(),
                          //   onTap: () => goToSettingsGeneral(context, this),
                          // ),
                          ListTile(
                            leading: const FaIcon(
                              FontAwesomeIcons.paintRoller,
                            ),
                            title: const Text('settings.appearance.appearance')
                                .tr(),
                            onTap: () => context.go('/settings/appearance'),
                          ),
                          ListTile(
                            title:
                                const Text('settings.language.language').tr(),
                            leading: const Icon(Icons.translate),
                            onTap: () => context.go('/settings/language'),
                          ),
                          ListTile(
                            title: const Text('download.download').tr(),
                            leading: const FaIcon(FontAwesomeIcons.download),
                            onTap: () => context.go('/settings/download'),
                          ),
                          ListTile(
                            title: const Text(
                              'settings.performance.performance',
                            ).tr(),
                            leading: const FaIcon(FontAwesomeIcons.gear),
                            onTap: () => context.go('/settings/performance'),
                          ),
                          ListTile(
                            title: const Text('settings.search').tr(),
                            leading: const FaIcon(
                              FontAwesomeIcons.magnifyingGlass,
                            ),
                            onTap: () => context.go('/settings/search'),
                          ),
                          ListTile(
                            title: const Text('settings.privacy.privacy').tr(),
                            leading:
                                const FaIcon(FontAwesomeIcons.shieldHalved),
                            onTap: () => context.go('/settings/privacy'),
                          ),
                          const Divider(),
                          _SettingsSection(
                            label: 'settings.other_settings'.tr(),
                          ),
                          ListTile(
                            title: const Text('settings.changelog').tr(),
                            leading: const FaIcon(
                              FontAwesomeIcons.solidNoteSticky,
                            ),
                            onTap: () => context.go('/settings/changelog'),
                          ),
                          ListTile(
                            title: const Text('settings.debug_logs.debug_logs')
                                .tr(),
                            leading: const FaIcon(FontAwesomeIcons.bug),
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const DebugLogsPage())),
                          ),
                          ListTile(
                            title:
                                const Text('settings.help_us_translate').tr(),
                            leading: const Icon(Icons.language),
                            onTap: () => launchExternalUrlString(
                                appInfo.translationProjectUrl),
                          ),
                          ListTile(
                            title: const Text('settings.information').tr(),
                            leading: const Icon(Icons.info),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => const AboutPage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _Divider(),
                  const _Footer(),
                ],
              ),
            ),
          )
        : const _LargeLayout();
  }
}

class _LargeLayout extends ConsumerStatefulWidget {
  const _LargeLayout();

  @override
  ConsumerState<_LargeLayout> createState() => _LargeLayoutState();
}

//TODO: refactor this when having more settings, this is a terrible design.
class _LargeLayoutState extends ConsumerState<_LargeLayout> {
  final currentTab = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    final package = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        elevation: 0,
        title: Text('settings.settings'.tr()),
      ),
      body: ValueListenableBuilder<int>(
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
                        title:
                            const Text('settings.appearance.appearance').tr(),
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
                          applicationVersion: package.version,
                          applicationLegalese:
                              '\u{a9} 2020-2022 Nguyen Duc Khoa',
                          applicationName: ref.watch(appInfoProvider).appName,
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
                  children: const [
                    AppearancePage(
                      hasAppBar: false,
                    ),
                    LanguagePage(
                      hasAppBar: false,
                    ),
                    PrivacyPage(
                      hasAppBar: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

class _Footer extends ConsumerWidget {
  const _Footer({
    this.mainAxisAlignment,
  });

  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(ref.read(appInfoProvider).githubUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const FaIcon(FontAwesomeIcons.squareGithub),
          ),
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(ref.read(appInfoProvider).discordUrl),
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
