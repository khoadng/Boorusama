// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/settings/appearance_page.dart';
import 'package:boorusama/core/ui/settings/download_page.dart';
import 'package:boorusama/core/ui/settings/general_page.dart';
import 'package:boorusama/core/ui/settings/language_page.dart';
import 'package:boorusama/core/ui/settings/performance_page.dart';
import 'package:boorusama/core/ui/settings/privacy_page.dart';
import 'package:boorusama/core/ui/settings/search_settings_page.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';

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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
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
    final packageInfo = ref.watch(packageInfoProvider);

    return ValueListenableBuilder<int>(
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
                    textColor: index == 0 ? Colors.white : null,
                    tileColor: index == 0 ? Colors.grey[800] : null,
                    title: const Text('settings.general').tr(),
                    onTap: () => currentTab.value = 0,
                  ),
                  ListTile(
                    textColor: index == 1 ? Colors.white : null,
                    tileColor: index == 1 ? Colors.grey[800] : null,
                    title: const Text('settings.appearance.appearance').tr(),
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
                    title: const Text('download.download').tr(),
                    onTap: () => currentTab.value = 3,
                  ),
                  ListTile(
                    textColor: index == 4 ? Colors.white : null,
                    tileColor: index == 4 ? Colors.grey[800] : null,
                    title: const Text('settings.performance.performance').tr(),
                    onTap: () => currentTab.value = 4,
                  ),
                  ListTile(
                    textColor: index == 5 ? Colors.white : null,
                    tileColor: index == 5 ? Colors.grey[800] : null,
                    title: const Text('settings.search').tr(),
                    onTap: () => currentTab.value = 5,
                  ),
                  ListTile(
                    textColor: index == 6 ? Colors.white : null,
                    tileColor: index == 6 ? Colors.grey[800] : null,
                    title: const Text('settings.privacy.privacy').tr(),
                    onTap: () => currentTab.value = 6,
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
                      applicationVersion: packageInfo.version,
                      applicationLegalese: '\u{a9} 2020-2023 Nguyen Duc Khoa',
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
                GeneralPage(
                  hasAppBar: false,
                ),
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
                SearchSettingsPage(
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
