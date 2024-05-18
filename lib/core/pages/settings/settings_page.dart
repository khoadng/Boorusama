// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/pages/settings/about_page.dart';
import 'package:boorusama/core/pages/settings/debug_logs_page.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'help_us_translate_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    this.scrollTo,
  });

  final String? scrollTo;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.scrollTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollTo == 'support') {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = ref.watch(appInfoProvider);
    ref.watch(settingsProvider.select((value) => value.language));
    final booruBuilder = ref.watch(booruBuilderProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.settings'.tr())),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
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
                        Symbols.translate,
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
                        FontAwesomeIcons.gaugeSimpleHigh,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/performance'),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.data_and_storage.data_and_storage',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.database,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/data_and_storage'),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.backup_and_restore.backup_and_restore',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
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
                        'settings.accessibility.accessibility',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.universalAccess,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/accessibility'),
                    ),
                    ListTile(
                      title: const Text(
                        'Image Viewer',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.image,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => context.go('/settings/image_viewer'),
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
                    if (booruBuilder != null) ...[
                      const Divider(),
                      _SettingsSection(
                        label: 'settings.booru_settings.booru_settings'.tr(),
                      ),
                      ListTile(
                        title: Text(
                          'settings.booru_settings.edit_current_profile'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        leading: FaIcon(
                          FontAwesomeIcons.gear,
                          color: context.iconTheme.color,
                          size: 20,
                        ),
                        onTap: () => context
                            .push('/boorus/${ref.watchConfig.id}/update'),
                      ),
                    ],
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
                      onTap: () => context.navigator.push(CupertinoPageRoute(
                          builder: (_) => const DebugLogsPage())),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.information',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: Icon(
                        Symbols.info,
                        color: context.iconTheme.color,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const AboutPage(),
                      ),
                    ),
                    const Divider(),
                    _SettingsSection(
                      // label: 'Contribute',
                      label: 'settings.contribute'.tr(),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.help_us_translate',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: Icon(
                        Symbols.language,
                        color: context.iconTheme.color,
                      ),
                      onTap: () => context.navigator.push(
                        CupertinoPageRoute(
                          builder: (_) => const HelpUseTranslatePage(),
                        ),
                      ),
                    ),
                    // Source code
                    ListTile(
                      title: const Text(
                        'settings.source_code',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      leading: FaIcon(
                        FontAwesomeIcons.code,
                        color: context.iconTheme.color,
                        size: 20,
                      ),
                      onTap: () => launchExternalUrl(
                        Uri.parse(appInfo.githubUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    const Divider(),
                    _SettingsSection(
                      label: 'settings.support'.tr(),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.contact_developer',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      subtitle: const Text(
                        'settings.contact_developer_description',
                      ).tr(),
                      leading: Icon(
                        Symbols.email,
                        color: context.iconTheme.color,
                      ),
                      onTap: () => launchExternalUrl(
                        Uri.parse('mailto:${appInfo.supportEmail}'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'settings.feature_request_and_bug_report',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ).tr(),
                      subtitle: const Text(
                        'settings.feature_request_and_bug_report_description',
                      ).tr(),
                      leading: Icon(
                        Symbols.bug_report,
                        color: context.iconTheme.color,
                      ),
                      onTap: () => launchExternalUrl(
                        Uri.parse('${appInfo.githubUrl}/issues'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    const SizedBox(height: 16),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
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
