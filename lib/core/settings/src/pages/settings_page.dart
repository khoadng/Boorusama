// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../../../../foundation/info/app_info.dart';
import '../../../../foundation/info/package_info.dart';
import '../../../../foundation/url_launcher.dart';
import '../../../analytics/providers.dart';
import '../../../boorus/engine/providers.dart';
import '../../../build_info/providers.dart';
import '../../../changelogs/routes.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/create/routes.dart';
import '../../../debug/routes.dart';
import '../../../developer_options/l10n.dart';
import '../../../developer_options/widgets.dart';
import '../../../premiums/providers.dart';
import '../../../premiums/routes.dart';
import '../../../premiums/types.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_page_scaffold.dart';
import 'about_page.dart';
import 'accessibility_page.dart';
import 'appearance/appearance_page.dart';
import 'backup_and_restore_page.dart';
import 'data_and_storage_page.dart';
import 'download_page.dart';
import 'help_us_translate_page.dart';
import 'image_viewer_page.dart';
import 'language_page.dart';
import 'privacy_page.dart';
import 'search_settings_page.dart';

List<SettingEntry> _entries(
  BuildContext context, {
  required bool showDeveloperOptions,
}) => [
  SettingEntry(
    id: 'appearance',
    name: '/settings/appearance',
    title: context.t.settings.appearance.appearance,
    icon: FontAwesomeIcons.paintRoller,
    content: const AppearancePage(),
  ),
  SettingEntry(
    id: 'language',
    name: '/settings/language',
    title: context.t.settings.language.language,
    icon: FontAwesomeIcons.language,
    content: const LanguagePage(),
  ),
  SettingEntry(
    id: 'download',
    name: '/settings/download',
    title: context.t.settings.download.title,
    icon: FontAwesomeIcons.download,
    content: const DownloadPage(),
  ),
  SettingEntry(
    id: 'data_and_storage',
    name: '/settings/data_and_storage',
    title: context.t.settings.data_and_storage.data_and_storage,
    icon: FontAwesomeIcons.database,
    content: const DataAndStoragePage(),
  ),
  SettingEntry(
    id: 'backup_and_restore',
    name: '/settings/backup_and_restore',
    title: context.t.settings.backup_and_restore.backup_and_restore,
    icon: FontAwesomeIcons.cloudArrowDown,
    content: const BackupAndRestorePage(),
  ),
  SettingEntry(
    id: 'search',
    name: '/settings/search',
    title: context.t.settings.search.search,
    icon: FontAwesomeIcons.magnifyingGlass,
    content: const SearchSettingsPage(),
  ),
  SettingEntry(
    id: 'accessibility',
    name: '/settings/accessibility',
    title: context.t.settings.accessibility.accessibility,
    icon: FontAwesomeIcons.universalAccess,
    content: const AccessibilityPage(),
  ),
  SettingEntry(
    id: 'viewer',
    name: '/settings/image_viewer',
    title: context.t.settings.image_viewer.image_viewer,
    icon: FontAwesomeIcons.image,
    content: const ImageViewerPage(),
  ),
  SettingEntry(
    id: 'privacy',
    name: '/settings/privacy',
    title: context.t.settings.privacy.privacy,
    icon: FontAwesomeIcons.shieldHalved,
    content: const PrivacyPage(),
  ),
  if (showDeveloperOptions)
    SettingEntry(
      id: 'developer_options',
      name: '/settings/developer_options',
      title: context.t.developerOptions.title,
      icon: FontAwesomeIcons.code,
      content: const DeveloperOptionsPage(),
    ),
];

const double _kThresholdWidth = 650;

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    this.scrollTo,
    this.initial,
  });

  final String? scrollTo;
  final String? initial;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _selected = ValueNotifier<String?>(null);
  final _nestedEntry = ValueNotifier<SettingEntry?>(null);

  @override
  Widget build(BuildContext context) {
    final entries = _entries(
      context,
      showDeveloperOptions: ref.watch(isDevEnvironmentProvider),
    );

    void openContent(BuildContext context, SettingEntry entry) {
      final options = SettingsPageScope.of(context).options;

      if (options.dense) {
        _nestedEntry.value = entry;
        return;
      }

      Navigator.of(context).push(
        CupertinoPageRoute(
          settings: RouteSettings(
            name: entry.name,
          ),
          builder: (_) => SettingsPageNavigationScope(
            openContent: openContent,
            child: SettingsPageScope(
              options: options,
              child: entry.content,
            ),
          ),
        ),
      );
    }

    return Theme(
      data: Kurumi.themeOf(context).copyWith(
        iconTheme: Kurumi.themeOf(context).iconTheme.copyWith(
          size: 18,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.settings.settings),
        ),
        body: SettingsPageNavigationScope(
          openContent: openContent,
          child: SettingsPageDynamicScope(
            options: SettingsPageDynamicOptions(
              scrollTo: widget.scrollTo,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                //TODO: Don't separate the settings page into two pages, merge them into one to prevent code duplication and unnecessary rebuilds when resizing the window
                return constraints.maxWidth > _kThresholdWidth
                    ? SettingsPageScope(
                        options: SettingsPageOptions(
                          showIcon: false,
                          dense: true,
                          entries: entries,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _selected,
                          builder: (_, selected, _) => ValueListenableBuilder(
                            valueListenable: _nestedEntry,
                            builder: (_, nestedEntry, _) => SettingsLargePage(
                              initial: selected ?? widget.initial,
                              onTabChanged: (tab) {
                                _selected.value = tab;
                                _nestedEntry.value = null;
                              },
                              nestedEntry: nestedEntry,
                            ),
                          ),
                        ),
                      )
                    : SettingsPageScope(
                        options: SettingsPageOptions(
                          showIcon: true,
                          dense: false,
                          entries: entries,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _selected,
                          builder: (_, selected, _) => SettingsSmallPage(
                            initial: selected ?? widget.initial,
                          ),
                        ),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _selected.dispose();
    _nestedEntry.dispose();
    super.dispose();
  }
}

class SettingsSmallPage extends ConsumerStatefulWidget {
  const SettingsSmallPage({
    super.key,
    this.initial,
  });

  final String? initial;

  @override
  ConsumerState<SettingsSmallPage> createState() => _SettingsSmallPageState();
}

class _SettingsSmallPageState extends ConsumerState<SettingsSmallPage> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;

    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // open the initial page
        final entry = _findInitialPage(initial);
        final openContent = SettingsPageNavigationScope.of(context).openContent;

        if (entry != null) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              settings: RouteSettings(
                name: entry.name,
              ),
              builder: (_) => SettingsPageNavigationScope(
                openContent: openContent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SettingsPageScope(
                        options: SettingsPageScope.of(context).options,
                        child: entry.content,
                      ),
                    ),
                    const WidthThresholdPopper(
                      targetWidth: _kThresholdWidth,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final scrollTo = SettingsPageDynamicScope.of(context).options.scrollTo;

    if (scrollTo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollTo == 'support') {
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

  SettingEntry? _findInitialPage(String initial) {
    final options = SettingsPageScope.of(context).options;
    for (final entry in options.entries) {
      // fuzzy search
      if (entry.id.toLowerCase().contains(initial.toLowerCase())) {
        return entry;
      }
    }

    return null;
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider.select((value) => value.language));
    final options = SettingsPageScope.of(context).options;
    final openContent = SettingsPageNavigationScope.of(context).openContent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsSection(
                  label: context.t.settings.app_settings,
                ),
                for (final entry in options.entries) ...[
                  SettingTile(
                    title: entry.title,
                    leading: SettingEntryIcon(icon: entry.icon),
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        settings: RouteSettings(
                          name: entry.name,
                        ),
                        builder: (_) => SettingsPageNavigationScope(
                          openContent: openContent,
                          child: SettingsPageScope(
                            options: options,
                            child: entry.content,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SettingsPageOtherSection(),
              ],
            ),
          ),
        ),
        const _Divider(),
        const _Footer(),
      ],
    );
  }
}

class SettingsLargePage extends ConsumerStatefulWidget {
  const SettingsLargePage({
    super.key,
    this.initial,
    this.onTabChanged,
    this.nestedEntry,
  });

  final String? initial;
  final void Function(String tab)? onTabChanged;
  final SettingEntry? nestedEntry;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SettingsLargePageState();
}

class _SettingsLargePageState extends ConsumerState<SettingsLargePage> {
  late var _selectedEntry = _findInitialIndex(widget.initial);

  int _findInitialIndex(String? initial) {
    if (initial == null) {
      return 0;
    }

    final options = SettingsPageScope.of(context).options;
    for (final entry in options.entries) {
      // fuzzy search
      final normalizedInitial = initial.toLowerCase();
      if (entry.id.toLowerCase() == normalizedInitial ||
          entry.title.toLowerCase().contains(normalizedInitial)) {
        return options.entries.indexOf(entry);
      }
    }

    return 0;
  }

  @override
  void didUpdateWidget(covariant SettingsLargePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initial != oldWidget.initial) {
      _selectedEntry = _findInitialIndex(widget.initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = SettingsPageScope.of(context).options.entries;
    final nestedEntry = widget.nestedEntry;
    final selectedContent =
        nestedEntry?.content ?? entries[_selectedEntry].content;

    // ref.watch(settingsProvider.select((value) => value.language));
    final options = SettingsPageScope.of(context).options;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 240,
          child: ListView(
            children: [
              for (final entry in entries)
                SettingTile(
                  title: entry.title,
                  leading: SettingEntryIcon(icon: entry.icon),
                  selected: entries.indexOf(entry) == _selectedEntry,
                  showLeading: options.showIcon,
                  onTap: () => setState(() {
                    _selectedEntry = entries.indexOf(entry);
                    ref
                        .read(analyticsProvider)
                        .whenData(
                          (a) => a?.logScreenView(entry.name),
                        );

                    widget.onTabChanged?.call(entry.id);
                  }),
                ),
              const SettingsPageOtherSection(),
              const _Divider(),
              const _Footer(),
            ],
          ),
        ),
        const VerticalDivider(
          width: 1,
        ),
        Flexible(
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: selectedContent,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsPageOtherSection extends ConsumerWidget {
  const SettingsPageOtherSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (booruBuilder != null) ...[
          const Divider(),
          _SettingsSection(
            label: context.t.settings.booru_settings.booru_settings,
          ),
          SettingTile(
            title: context.t.settings.booru_settings.edit_current_profile,
            leading: const FaIcon(
              FontAwesomeIcons.gear,
            ),
            onTap: () => goToUpdateBooruConfigPage(
              ref,
              config: ref.watchConfig,
            ),
          ),
        ],
        const Divider(),
        _SettingsSection(
          label: context.t.settings.other_settings,
        ),
        if (ref.watch(hasPremiumProvider))
          ref
              .watch(premiumManagementURLProvider)
              .maybeWhen(
                data: (url) => SettingTile(
                  title: 'Manage Subscription',
                  leading: const FaIcon(
                    FontAwesomeIcons.solidStar,
                  ),
                  onTap: () => url != null
                      ? launchExternalUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        )
                      : Kurumi.showErrorToast(
                          context,
                          'Failed to open subscription management',
                        ),
                ),
                orElse: () => SettingTile(
                  title: 'Manage Subscription',
                  leading: const FaIcon(
                    FontAwesomeIcons.solidStar,
                  ),
                  onTap: () {
                    Kurumi.showErrorToast(
                      context,
                      'Failed to open subscription management',
                    );
                  },
                ),
              )
        else if (ref.watch(showPremiumFeatsProvider) && !kForcePremium)
          SettingTile(
            title: kPremiumBrandNameFull,
            leading: const FaIcon(
              FontAwesomeIcons.solidStar,
            ),
            onTap: () => goToPremiumPage(ref),
          ),
        SettingTile(
          title: context.t.settings.changelog,
          leading: const FaIcon(
            FontAwesomeIcons.solidNoteSticky,
          ),
          onTap: () => goToChangelogPage(ref),
        ),
        SettingTile(
          title: context.t.settings.debug_logs.debug_logs,
          leading: const FaIcon(
            FontAwesomeIcons.bug,
          ),
          onTap: () => goToDebuglogPage(ref),
        ),
        Builder(
          builder: (context) {
            final buildInfo = ref.watch(buildInfoProvider);
            final packageInfo = ref.watch(packageInfoProvider);
            final versionString = context.t.generic.version(
              version: packageInfo.version,
            );

            return SettingTile(
              title: context.t.settings.information,
              subtitle: switch (buildInfo) {
                final info? => info.toInfoString(
                  versionString,
                  formatTimestamp: (timestamp) =>
                      '${context.t.comment.list.last_updated}: ${timestamp.fuzzify(
                        locale: Localizations.localeOf(context),
                      )}',
                ),
                null => versionString,
              },
              leading: const FaIcon(
                FontAwesomeIcons.circleInfo,
              ),
              onTap: () => showDialog(
                context: context,
                builder: (context) => const AboutPage(),
              ),
            );
          },
        ),
        const Divider(),
        _SettingsSection(
          label: context.t.settings.contribute,
        ),
        SettingTile(
          title: context.t.settings.help_us_translate,
          leading: const FaIcon(
            FontAwesomeIcons.language,
          ),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const HelpUseTranslatePage(),
            ),
          ),
        ),
        SettingTile(
          title: context.t.settings.source_code,
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
          label: context.t.settings.support,
        ),
        SettingTile(
          title: context.t.settings.contact_developer,
          subtitle: context.t.settings.contact_developer_description,
          leading: const FaIcon(
            FontAwesomeIcons.envelope,
          ),
          onTap: () => launchExternalUrl(
            Uri.parse('mailto:${appInfo.supportEmail}'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        SettingTile(
          title: context.t.settings.feature_request_and_bug_report,
          subtitle:
              context.t.settings.feature_request_and_bug_report_description,
          leading: const FaIcon(
            FontAwesomeIcons.bug,
          ),
          onTap: () => launchExternalUrl(
            Uri.parse('${appInfo.githubUrl}/issues'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.title,
    required this.leading,
    super.key,
    this.onTap,
    this.showLeading,
    this.subtitle,
    this.selected,
  });

  final bool? showLeading;
  final String title;
  final void Function()? onTap;
  final Widget leading;
  final String? subtitle;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final options = SettingsPageScope.of(context).options;
    final showIcon = showLeading ?? options.showIcon;
    final dense = options.dense;

    return KurumiSettingsEntryTile(
      title: title,
      leading: leading,
      onTap: onTap,
      showLeading: showIcon,
      subtitle: subtitle,
      selected: selected ?? false,
      dense: dense,
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
        style: Kurumi.themeOf(context).textTheme.titleSmall?.copyWith(
          color: Kurumi.themeOf(context).colorScheme.hintColor,
        ),
      ),
    );
  }
}
