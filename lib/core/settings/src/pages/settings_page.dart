// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../core/widgets/widgets.dart';
import '../../../../foundation/info/app_info.dart';
import '../../../../foundation/scrolling.dart';
import '../../../../foundation/toast.dart';
import '../../../../foundation/url_launcher.dart';
import '../../../analytics/providers.dart';
import '../../../boorus/engine/providers.dart';
import '../../../configs/create/routes.dart';
import '../../../configs/ref.dart';
import '../../../premiums/premiums.dart';
import '../../../premiums/providers.dart';
import '../../../premiums/routes.dart';
import '../../../theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_page_scaffold.dart';
import 'about_page.dart';
import 'accessibility_page.dart';
import 'appearance/appearance_page.dart';
import 'backup_restore/backup_and_restore_page.dart';
import 'changelog_page.dart';
import 'data_and_storage_page.dart';
import 'debug_logs_page.dart';
import 'download_page.dart';
import 'help_us_translate_page.dart';
import 'image_viewer_page.dart';
import 'language_page.dart';
import 'privacy_page.dart';
import 'search_settings_page.dart';

List<SettingEntry> _entries(BuildContext context) => [
      SettingEntry(
        name: '/settings/appearance',
        title: context.t.settings.appearance.appearance,
        icon: FontAwesomeIcons.paintRoller,
        content: const AppearancePage(),
      ),
      SettingEntry(
        name: '/settings/language',
        title: context.t.settings.language.language,
        icon: Symbols.translate,
        content: const LanguagePage(),
      ),
      SettingEntry(
        name: '/settings/download',
        title: context.t.settings.download.title,
        icon: FontAwesomeIcons.download,
        content: const DownloadPage(),
      ),
      SettingEntry(
        name: '/settings/data_and_storage',
        title: context.t.settings.data_and_storage.data_and_storage,
        icon: FontAwesomeIcons.database,
        content: const DataAndStoragePage(),
      ),
      SettingEntry(
        name: '/settings/backup_and_restore',
        title: context.t.settings.backup_and_restore.backup_and_restore,
        icon: FontAwesomeIcons.cloudArrowDown,
        content: const BackupAndRestorePage(),
      ),
      SettingEntry(
        name: '/settings/search',
        title: context.t.settings.search.search,
        icon: FontAwesomeIcons.magnifyingGlass,
        content: const SearchSettingsPage(),
      ),
      SettingEntry(
        name: '/settings/accessibility',
        title: context.t.settings.accessibility.accessibility,
        icon: FontAwesomeIcons.universalAccess,
        content: const AccessibilityPage(),
      ),
      SettingEntry(
        name: '/settings/image_viewer',
        title: context.t.settings.image_viewer.image_viewer,
        icon: FontAwesomeIcons.image,
        content: const ImageViewerPage(),
      ),
      SettingEntry(
        name: '/settings/privacy',
        title: context.t.settings.privacy.privacy,
        icon: FontAwesomeIcons.shieldHalved,
        content: const PrivacyPage(),
      ),
    ];

const double _kThresholdWidth = 650;

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.scrollTo,
    this.initial,
  });

  final String? scrollTo;
  final String? initial;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _selected = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    final entries = _entries(context);

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(
          size: 18,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.settings.settings),
        ),
        body: SettingsPageDynamicScope(
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
                        builder: (_, selected, _) => SettingsLargePage(
                          initial: selected ?? widget.initial,
                          onTabChanged: (tab) => _selected.value = tab,
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
    );
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

        if (entry != null) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              settings: RouteSettings(
                name: entry.name,
              ),
              builder: (_) => Column(
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
      if (entry.title.toLowerCase().contains(initial.toLowerCase())) {
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
                    title: entry.title == 'settings.appearance.appearance'
                        ? context.t.settings.appearance.appearance
                        : entry.title == 'settings.language.language'
                            ? context.t.settings.language.language
                            : entry.title == 'settings.download.title'
                                ? context.t.settings.download.title
                                : entry.title ==
                                        'settings.data_and_storage.data_and_storage'
                                    ? context.t.settings.data_and_storage
                                        .data_and_storage
                                    : entry.title ==
                                            'settings.backup_and_restore.backup_and_restore'
                                        ? context.t.settings.backup_and_restore
                                            .backup_and_restore
                                        : entry.title ==
                                                'settings.search.search'
                                            ? context.t.settings.search.search
                                            : entry.title ==
                                                    'settings.accessibility.accessibility'
                                                ? context.t.settings
                                                    .accessibility.accessibility
                                                : entry.title ==
                                                        'settings.image_viewer.image_viewer'
                                                    ? context
                                                        .t
                                                        .settings
                                                        .image_viewer
                                                        .image_viewer
                                                    : entry.title ==
                                                            'settings.privacy.privacy'
                                                        ? context.t.settings
                                                            .privacy.privacy
                                                        : entry.title,
                    leading: FaIcon(
                      entry.icon,
                    ),
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        settings: RouteSettings(
                          name: entry.name,
                        ),
                        builder: (_) => SettingsPageScope(
                          options: options,
                          child: entry.content,
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
  });

  final String? initial;
  final void Function(String tab)? onTabChanged;

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
      if (entry.title.toLowerCase().contains(initial.toLowerCase())) {
        return options.entries.indexOf(entry);
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final entries = SettingsPageScope.of(context).options.entries;

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
                  leading: FaIcon(
                    entry.icon,
                  ),
                  selected: entries.indexOf(entry) == _selectedEntry,
                  showLeading: options.showIcon,
                  onTap: () => setState(() {
                    _selectedEntry = entries.indexOf(entry);
                    ref
                        .read(analyticsProvider)
                        .whenData(
                          (a) => a?.logScreenView(entry.name),
                        );

                    widget.onTabChanged?.call(entry.title);
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
              child: entries[_selectedEntry].content,
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
    final options = SettingsPageScope.of(context).options;

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
                      : showErrorToast(
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
                    showErrorToast(
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
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const ChangelogPage(),
            ),
          ),
        ),
        SettingTile(
          title: context.t.settings.debug_logs.debug_logs,
          leading: const FaIcon(
            FontAwesomeIcons.bug,
          ),
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => SettingsPageScope(
                options: options,
                child: const DebugLogsPage(),
              ),
            ),
          ),
        ),
        SettingTile(
          title: context.t.settings.information,
          leading: const FaIcon(
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
          label: context.t.settings.contribute,
        ),
        SettingTile(
          title: context.t.settings.help_us_translate,
          leading: const FaIcon(
            Symbols.language,
            size: 24,
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
            Symbols.email,
            size: 24,
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
            Symbols.bug_report,
            size: 24,
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      child: Material(
        color: selected == true
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
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
                if (showIcon)
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 32,
                    ),
                    margin: const EdgeInsets.only(
                      left: 4,
                    ),
                    child: leading,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: selected == true
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.hintColor,
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.hintColor,
        ),
      ),
    );
  }
}
