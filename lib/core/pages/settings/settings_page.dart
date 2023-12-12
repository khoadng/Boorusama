// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/pages/settings/about_page.dart';
import 'package:boorusama/core/pages/settings/debug_logs_page.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
                    ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.paintRoller,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      title: const Text(
                        'settings.appearance.appearance',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      onTap: () => context.go('/settings/appearance'),
                    ),
                    ListTile(
                      title: const Text('settings.language.language',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          )).tr(),
                      leading: Icon(
                        Icons.translate,
                        color: context.iconTheme.color,
                      ),
                      onTap: () => context.go('/settings/language'),
                    ),
                    ListTile(
                      title: const Text(
                        'download.download',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.download,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/download'),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.performance.performance',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.gear,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/performance'),
                    ),
                    ListTile(
                      title: const Text(
                        'Data and Storage',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      leading: FaIcon(
                        FontAwesomeIcons.database,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/data_and_storage'),
                    ),
                    ListTile(
                      title: const Text(
                        'Backup and Restore',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      leading: FaIcon(
                        FontAwesomeIcons.cloudArrowDown,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/backup_and_restore'),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.search.search',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/search'),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.privacy.privacy',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.shieldHalved,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/privacy'),
                    ),
                    const Divider(),
                    _SettingsSection(
                      label: 'settings.other_settings'.tr(),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.changelog',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.solidNoteSticky,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/changelog'),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.debug_logs.debug_logs',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.bug,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.navigator.push(MaterialPageRoute(
                          builder: (_) => const DebugLogsPage())),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.help_us_translate',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: Icon(
                        Icons.language,
                        color: context.iconTheme.color,
                      ),
                      onTap: () => launchExternalUrlString(
                          appInfo.translationProjectUrl),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.information',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: Icon(
                        Icons.info,
                        color: context.iconTheme.color,
                      ),
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
