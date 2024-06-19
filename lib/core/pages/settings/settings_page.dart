// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
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
import 'package:boorusama/foundation/scrolling.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'help_us_translate_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    this.scrollTo,
    this.largeScreen = false,
  });

  final String? scrollTo;
  final bool largeScreen;

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
          scrollController.animateToWithAccessibility(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            reduceAnimations: ref.read(settingsProvider).reduceAnimations,
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
    return Scaffold(
      appBar: !widget.largeScreen
          ? AppBar(
              title: Text(
                'settings.settings'.tr(),
              ),
            )
          : null,
      body: SettingsPageScope(
        options: SettingsPageOptions(
          showIcon: !widget.largeScreen,
          dense: widget.largeScreen,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  size: 20,
                ),
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final appInfo = ref.watch(appInfoProvider);
    ref.watch(settingsProvider.select((value) => value.language));
    final booruBuilder = ref.watch(booruBuilderProvider);
    return Padding(
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
                  SettingTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.paintRoller,
                    ),
                    title: 'settings.appearance.appearance'.tr(),
                    onTap: () => context.go('/settings/appearance'),
                  ),
                  SettingTile(
                    title: 'settings.language.language'.tr(),
                    leading: const Icon(
                      Symbols.translate,
                      size: 24,
                    ),
                    onTap: () => context.go('/settings/language'),
                  ),
                  SettingTile(
                    title: 'download.download'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.download,
                    ),
                    onTap: () => context.go('/settings/download'),
                  ),
                  SettingTile(
                    title: 'settings.performance.performance'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.gaugeSimpleHigh,
                    ),
                    onTap: () => context.go('/settings/performance'),
                  ),
                  SettingTile(
                    title: 'settings.data_and_storage.data_and_storage'.tr(),
                    onTap: () => context.go('/settings/data_and_storage'),
                    leading: const FaIcon(
                      FontAwesomeIcons.database,
                    ),
                  ),
                  SettingTile(
                    title:
                        'settings.backup_and_restore.backup_and_restore'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.cloudArrowDown,
                    ),
                    onTap: () => context.go('/settings/backup_and_restore'),
                  ),
                  SettingTile(
                    title: 'settings.search.search'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                    ),
                    onTap: () => context.go('/settings/search'),
                  ),
                  SettingTile(
                    title: 'settings.accessibility.accessibility'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.universalAccess,
                    ),
                    onTap: () => context.go('/settings/accessibility'),
                  ),
                  SettingTile(
                    title: 'Image Viewer',
                    leading: const FaIcon(
                      FontAwesomeIcons.image,
                    ),
                    onTap: () => context.go('/settings/image_viewer'),
                  ),
                  SettingTile(
                    title: 'settings.privacy.privacy'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.shieldHalved,
                    ),
                    onTap: () => context.go('/settings/privacy'),
                  ),
                  if (booruBuilder != null) ...[
                    const Divider(),
                    _SettingsSection(
                      label: 'settings.booru_settings.booru_settings'.tr(),
                    ),
                    SettingTile(
                      title:
                          'settings.booru_settings.edit_current_profile'.tr(),
                      leading: const FaIcon(
                        FontAwesomeIcons.gear,
                      ),
                      onTap: () =>
                          context.push('/boorus/${ref.watchConfig.id}/update'),
                    ),
                  ],
                  const Divider(),
                  _SettingsSection(
                    label: 'settings.other_settings'.tr(),
                  ),
                  SettingTile(
                    title: 'settings.changelog'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.solidNoteSticky,
                    ),
                    onTap: () => context.go('/settings/changelog'),
                  ),
                  SettingTile(
                    title: 'settings.debug_logs.debug_logs'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.bug,
                    ),
                    onTap: () => context.navigator.push(CupertinoPageRoute(
                        builder: (_) => const DebugLogsPage())),
                  ),
                  SettingTile(
                    title: 'settings.information'.tr(),
                    leading: const Icon(
                      Symbols.info,
                      size: 24,
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const AboutPage(),
                    ),
                  ),
                  const Divider(),
                  _SettingsSection(
                    label: 'settings.contribute'.tr(),
                  ),
                  SettingTile(
                    title: 'settings.help_us_translate'.tr(),
                    leading: const Icon(
                      Symbols.language,
                      size: 24,
                    ),
                    onTap: () => context.navigator.push(
                      CupertinoPageRoute(
                        builder: (_) => const HelpUseTranslatePage(),
                      ),
                    ),
                  ),
                  SettingTile(
                    title: 'settings.source_code'.tr(),
                    leading: const FaIcon(
                      FontAwesomeIcons.code,
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
                  SettingTile(
                    title: 'settings.contact_developer'.tr(),
                    subtitle: 'settings.contact_developer_description'.tr(),
                    leading: const Icon(
                      Symbols.email,
                      size: 24,
                    ),
                    onTap: () => launchExternalUrl(
                      Uri.parse('mailto:${appInfo.supportEmail}'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  SettingTile(
                    title: 'settings.feature_request_and_bug_report'.tr(),
                    subtitle:
                        'settings.feature_request_and_bug_report_description'
                            .tr(),
                    leading: const Icon(
                      Symbols.bug_report,
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
    );
  }
}

class SettingsPageOptions extends Equatable {
  const SettingsPageOptions({
    required this.showIcon,
    required this.dense,
  });

  final bool showIcon;
  final bool dense;

  @override
  List<Object?> get props => [showIcon, dense];
}

class SettingsPageScope extends InheritedWidget {
  const SettingsPageScope({
    super.key,
    required this.options,
    required super.child,
  });

  static SettingsPageScope of(BuildContext context) {
    final item =
        context.dependOnInheritedWidgetOfExactType<SettingsPageScope>();

    if (item == null) {
      throw FlutterError('SettingsPageScope.of was called with a context that '
          'does not contain a SettingsPageScope.');
    }

    return item;
  }

  final SettingsPageOptions options;

  @override
  bool updateShouldNotify(SettingsPageScope oldWidget) {
    return options != oldWidget.options;
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.title,
    required this.leading,
    this.onTap,
    this.showLeading,
    this.subtitle,
  });

  final bool? showLeading;
  final String title;
  final void Function()? onTap;
  final Widget leading;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final options = SettingsPageScope.of(context).options;
    final showIcon = showLeading ?? options.showIcon;
    final dense = options.dense;

    // final selected = options.selectedValue == title;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        // color: selected ? context.colorScheme.secondary : Colors.transparent,
        child: InkWell(
          hoverColor: context.theme.hoverColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(
              vertical: dense
                  ? 4
                  : subtitle != null
                      ? 6
                      : 10,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: showIcon ? 4 : 6,
            ),
            child: Row(
              children: [
                if (showIcon) leading,
                if (showIcon) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.theme.hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
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
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Text(
        label.toUpperCase(),
        style: context.textTheme.titleSmall!
            .copyWith(color: context.theme.hintColor),
      ),
    );
  }
}
