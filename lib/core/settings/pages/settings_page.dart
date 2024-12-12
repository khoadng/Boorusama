// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../core/widgets/widgets.dart';
import '../../boorus/providers.dart';
import '../../configs/ref.dart';
import '../../foundation/scrolling.dart';
import '../../foundation/url_launcher.dart';
import '../../info/app_info.dart';
import '../../router.dart';
import '../../theme.dart';
import '../data/settings_providers.dart';
import '../widgets/settings_page_scaffold.dart';
import 'about_page.dart';
import 'accessibility_page.dart';
import 'appearance_page.dart';
import 'backup_and_restore_page.dart';
import 'changelog_page.dart';
import 'data_and_storage_page.dart';
import 'debug_logs_page.dart';
import 'download_page.dart';
import 'help_us_translate_page.dart';
import 'image_viewer_page.dart';
import 'language_page.dart';
import 'privacy_page.dart';
import 'search_settings_page.dart';

const _entries = [
  SettingEntry(
    title: 'settings.appearance.appearance',
    icon: FontAwesomeIcons.paintRoller,
    content: AppearancePage(),
  ),
  SettingEntry(
    title: 'settings.language.language',
    icon: Symbols.translate,
    content: LanguagePage(),
  ),
  SettingEntry(
    title: 'settings.download.title',
    icon: FontAwesomeIcons.download,
    content: DownloadPage(),
  ),
  SettingEntry(
    title: 'settings.data_and_storage.data_and_storage',
    icon: FontAwesomeIcons.database,
    content: DataAndStoragePage(),
  ),
  SettingEntry(
    title: 'settings.backup_and_restore.backup_and_restore',
    icon: FontAwesomeIcons.cloudArrowDown,
    content: BackupAndRestorePage(),
  ),
  SettingEntry(
    title: 'settings.search.search',
    icon: FontAwesomeIcons.magnifyingGlass,
    content: SearchSettingsPage(),
  ),
  SettingEntry(
    title: 'settings.accessibility.accessibility',
    icon: FontAwesomeIcons.universalAccess,
    content: AccessibilityPage(),
  ),
  SettingEntry(
    title: 'settings.image_viewer.image_viewer',
    icon: FontAwesomeIcons.image,
    content: ImageViewerPage(),
  ),
  SettingEntry(
    title: 'settings.privacy.privacy',
    icon: FontAwesomeIcons.shieldHalved,
    content: PrivacyPage(),
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
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(
              size: 18,
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'settings.settings'.tr(),
          ),
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
                      options: const SettingsPageOptions(
                        showIcon: false,
                        dense: true,
                        entries: _entries,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _selected,
                        builder: (_, selected, __) => SettingsLargePage(
                          initial: selected ?? widget.initial,
                          onTabChanged: (tab) => _selected.value = tab,
                        ),
                      ),
                    )
                  : SettingsPageScope(
                      options: const SettingsPageOptions(
                        showIcon: true,
                        dense: false,
                        entries: _entries,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _selected,
                        builder: (_, selected, __) => SettingsSmallPage(
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
        final page = _findInitialPage(initial);

        if (page != null) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SettingsPageScope(
                      options: SettingsPageScope.of(context).options,
                      child: page,
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

  Widget? _findInitialPage(String initial) {
    final options = SettingsPageScope.of(context).options;
    for (final entry in options.entries) {
      // fuzzy search
      if (entry.title.toLowerCase().contains(initial.toLowerCase())) {
        return entry.content;
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
                  label: 'settings.app_settings'.tr(),
                ),
                for (final entry in options.entries) ...[
                  SettingTile(
                    title: entry.title.tr(),
                    leading: FaIcon(
                      entry.icon,
                    ),
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
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
                  title: entry.title.tr(),
                  leading: FaIcon(
                    entry.icon,
                  ),
                  selected: entries.indexOf(entry) == _selectedEntry,
                  showLeading: options.showIcon,
                  onTap: () => setState(() {
                    _selectedEntry = entries.indexOf(entry);
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
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final options = SettingsPageScope.of(context).options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (booruBuilder != null) ...[
          const Divider(),
          _SettingsSection(
            label: 'settings.booru_settings.booru_settings'.tr(),
          ),
          SettingTile(
            title: 'settings.booru_settings.edit_current_profile'.tr(),
            leading: const FaIcon(
              FontAwesomeIcons.gear,
            ),
            onTap: () => goToUpdateBooruConfigPage(
              context,
              config: ref.watchConfig,
            ),
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
          onTap: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const ChangelogPage(),
            ),
          ),
        ),
        SettingTile(
          title: 'settings.debug_logs.debug_logs'.tr(),
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
          title: 'settings.information'.tr(),
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
          label: 'settings.contribute'.tr(),
        ),
        SettingTile(
          title: 'settings.help_us_translate'.tr(),
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
          title: 'settings.feature_request_and_bug_report'.tr(),
          subtitle: 'settings.feature_request_and_bug_report_description'.tr(),
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
    super.key,
    required this.title,
    required this.leading,
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
          hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
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
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.hintColor),
      ),
    );
  }
}
