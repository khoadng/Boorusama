// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/settings/about_page.dart';
import 'package:boorusama/boorus/core/pages/settings/debug_logs_page.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    ref.watch(settingsProvider.select((value) => value.language));

    return Scaffold(
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
                    //           context.theme.colorScheme.primary,
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
                      title: const Text('settings.appearance.appearance').tr(),
                      onTap: () => context.go('/settings/appearance'),
                    ),
                    ListTile(
                      title: const Text('settings.language.language').tr(),
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
                      leading: const FaIcon(FontAwesomeIcons.shieldHalved),
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
                      title: const Text('settings.debug_logs.debug_logs').tr(),
                      leading: const FaIcon(FontAwesomeIcons.bug),
                      onTap: () => context.navigator.push(MaterialPageRoute(
                          builder: (_) => const DebugLogsPage())),
                    ),
                    ListTile(
                      title: const Text('settings.help_us_translate').tr(),
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
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
        style: context.textTheme.titleSmall!
            .copyWith(color: context.theme.hintColor),
      ),
    );
  }
}
