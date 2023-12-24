// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/pages/settings/appearance_page.dart';
import 'package:boorusama/core/pages/settings/backup_and_restore_page.dart';
import 'package:boorusama/core/pages/settings/data_and_storage_page.dart';
import 'package:boorusama/core/pages/settings/download_page.dart';
import 'package:boorusama/core/pages/settings/language_page.dart';
import 'package:boorusama/core/pages/settings/performance_page.dart';
import 'package:boorusama/core/pages/settings/privacy_page.dart';
import 'package:boorusama/core/pages/settings/search_settings_page.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'about_page.dart';
import 'changelog_page.dart';
import 'debug_logs_page.dart';

class SettingsPageDesktop extends StatelessWidget {
  const SettingsPageDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'settings.settings'.tr(),
              style: context.textTheme.titleLarge,
            ),
            const Spacer(),
            IconButton(
              splashRadius: 18,
              onPressed: () => context.navigator.pop(),
              icon: const Icon(Symbols.close),
            ),
          ],
        ),
        const Divider(
          thickness: 1.5,
        ),
        const Expanded(child: _LargeLayout()),
      ],
    );
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
    final appInfo = ref.watch(appInfoProvider);
    ref.watch(settingsProvider.select((value) => value.language));

    return ValueListenableBuilder(
      valueListenable: currentTab,
      builder: (context, index, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            primary: false,
            child: SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingsSection(
                    label: 'settings.app_settings'.tr(),
                  ),
                  ListTile(
                    textColor:
                        index == 0 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 0 ? context.colorScheme.secondary : null,
                    title: const Text('settings.appearance.appearance').tr(),
                    onTap: () => currentTab.value = 0,
                  ),
                  ListTile(
                    textColor:
                        index == 1 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 1 ? context.colorScheme.secondary : null,
                    title: const Text('settings.language.language').tr(),
                    onTap: () => currentTab.value = 1,
                  ),
                  ListTile(
                    textColor:
                        index == 2 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 2 ? context.colorScheme.secondary : null,
                    title: const Text('download.download').tr(),
                    onTap: () => currentTab.value = 2,
                  ),
                  ListTile(
                    textColor:
                        index == 3 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 3 ? context.colorScheme.secondary : null,
                    title: const Text('settings.performance.performance').tr(),
                    onTap: () => currentTab.value = 3,
                  ),
                  ListTile(
                    textColor:
                        index == 4 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 4 ? context.colorScheme.secondary : null,
                    title: const Text('Data and Storage'),
                    onTap: () => currentTab.value = 4,
                  ),
                  ListTile(
                    textColor:
                        index == 5 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 5 ? context.colorScheme.secondary : null,
                    title: const Text('Backup and Restore'),
                    onTap: () => currentTab.value = 5,
                  ),
                  ListTile(
                    textColor:
                        index == 6 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 6 ? context.colorScheme.secondary : null,
                    title: const Text('settings.search.search').tr(),
                    onTap: () => currentTab.value = 5,
                  ),
                  ListTile(
                    textColor:
                        index == 7 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 7 ? context.colorScheme.secondary : null,
                    title: const Text('settings.privacy.privacy').tr(),
                    onTap: () => currentTab.value = 6,
                  ),
                  ListTile(
                    textColor:
                        index == 8 ? context.colorScheme.onSecondary : null,
                    tileColor:
                        index == 8 ? context.colorScheme.secondary : null,
                    title: const Text('settings.debug_logs.debug_logs').tr(),
                    onTap: () => currentTab.value = 7,
                  ),
                  const Divider(
                    thickness: 0.8,
                    endIndent: 10,
                    indent: 10,
                  ),
                  ListTile(
                    title: const Text('settings.changelog').tr(),
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) => Container(
                              margin: const EdgeInsets.all(120),
                              child: const ChangelogPage(),
                            )),
                  ),
                  ListTile(
                    title: const Text('settings.help_us_translate').tr(),
                    onTap: () =>
                        launchExternalUrlString(appInfo.translationProjectUrl),
                  ),
                  ListTile(
                    title: const Text('settings.information').tr(),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const AboutPage(),
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
                DownloadPage(
                  hasAppBar: false,
                ),
                PerformancePage(
                  hasAppBar: false,
                ),
                DataAndStoragePage(
                  hasAppBar: false,
                ),
                BackupAndRestorePage(
                  hasAppBar: false,
                ),
                SearchSettingsPage(
                  hasAppBar: false,
                ),
                PrivacyPage(
                  hasAppBar: false,
                ),
                DebugLogsPage(
                  hasAppBar: false,
                ),
              ],
            ),
          ),
        ],
      ),
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
        style: context.textTheme.titleSmall!
            .copyWith(color: context.theme.hintColor),
      ),
    );
  }
}
