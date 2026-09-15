// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/cupertino.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
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
import '../providers/settings_navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../routes/settings_adaptive_page.dart';
import '../types/settings_navigation_state.dart';
import '../widgets/settings_page_scaffold.dart';
import 'about_page.dart';
import 'accessibility_page.dart';
import 'app_lock_settings_page.dart';
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

Map<String, SettingEntry> _destinations(
  BuildContext context,
  List<SettingEntry> entries,
) {
  final appLock = context.t.settings.privacy.app_lock;
  return {
    for (final entry in entries) entry.id: entry,
    'app_lock': SettingEntry(
      id: 'app_lock',
      parentId: 'privacy',
      name: '/settings/privacy/app_lock',
      title: appLock.title,
      icon: Icons.lock,
      content: const AppLockSettingsPage(),
    ),
  };
}

SettingsDestinationCatalog _destinationCatalog(
  List<SettingEntry> entries,
  Map<String, SettingEntry> destinations,
) => SettingsDestinationCatalog(
  categoryIds: entries.map((entry) => entry.id),
  parentById: {
    for (final entry in destinations.values) entry.id: ?entry.parentId,
  },
);

const double _kSettingsWideBreakpoint = 700;
const double _kSettingsSidebarWidth = 280;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    super.key,
    this.scrollTo,
    this.initial,
  });

  final String? scrollTo;
  final String? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = _entries(
      context,
      showDeveloperOptions: ref.watch(isDevEnvironmentProvider),
    );
    final destinations = _destinations(context, entries);
    final catalog = _destinationCatalog(entries, destinations);

    return Theme(
      data: Kurumi.themeOf(context).copyWith(
        iconTheme: Kurumi.themeOf(context).iconTheme.copyWith(
          size: 18,
        ),
      ),
      child: Scaffold(
        body: SettingsPageDynamicScope(
          options: SettingsPageDynamicOptions(scrollTo: scrollTo),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _kSettingsWideBreakpoint;
              return ProviderScope(
                overrides: [
                  settingsDestinationCatalogProvider.overrideWithValue(
                    catalog,
                  ),
                ],
                child: _SettingsAdaptiveShell(
                  wide: wide,
                  initial: initial,
                  entries: entries,
                  destinations: destinations,
                  scrollTo: scrollTo,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsAdaptiveShell extends ConsumerStatefulWidget {
  const _SettingsAdaptiveShell({
    required this.wide,
    required this.initial,
    required this.entries,
    required this.destinations,
    required this.scrollTo,
  });

  final bool wide;
  final String? initial;
  final List<SettingEntry> entries;
  final Map<String, SettingEntry> destinations;
  final String? scrollTo;

  @override
  ConsumerState<_SettingsAdaptiveShell> createState() =>
      _SettingsAdaptiveShellState();
}

class _SettingsAdaptiveShellState
    extends ConsumerState<_SettingsAdaptiveShell> {
  final _hostIdentity = Object();
  final _contentNavigatorKey = GlobalKey<NavigatorState>();
  final _compactIndexScrollController = ScrollController();
  final _sidebarScrollController = ScrollController();
  late final SettingsNavigationSeed _seed;
  var _compactScrollHandled = false;
  var _sidebarScrollHandled = false;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    final catalog = ref.read(settingsDestinationCatalogProvider);
    _seed = SettingsNavigationSeed(
      hostIdentity: _hostIdentity,
      initialPath: resolveSettingsInitialPath(
        catalog: catalog,
        presentation: widget.wide
            ? SettingsPresentation.wide
            : SettingsPresentation.compact,
        initialDestination: widget.initial,
      ).where(widget.destinations.containsKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = widget.wide;
    final entries = widget.entries;
    final destinations = widget.destinations;
    final navigation = ref.watch(settingsNavigationProvider(_seed));
    final notifier = ref.read(settingsNavigationProvider(_seed).notifier);
    final options = SettingsPageOptions(
      showIcon: true,
      dense: wide,
      entries: entries,
      shellOwnsHeader: true,
    );
    final applicationNavigator = Navigator.of(context);

    void closeHost() {
      if (_closing) return;
      setState(() => _closing = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) applicationNavigator.maybePop();
      });
    }

    void openContent(BuildContext _, SettingEntry entry) {
      notifier.openNested(entry.id);
    }

    _handleRequestedScroll(wide: wide);

    return SettingsPageNavigationScope(
      openContent: openContent,
      applicationNavigator: applicationNavigator,
      child: SettingsPageScope(
        options: options,
        child: _SettingsPresentationScope(
          wide: wide,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): closeHost,
            },
            child: PopScope<void>(
              canPop: _closing || !navigation.canGoBack,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && navigation.canGoBack) notifier.back();
              },
              child: Row(
                children: [
                  SizedBox(
                    width: wide ? _kSettingsSidebarWidth : 0,
                    child: wide
                        ? _SettingsSidebar(
                            entries: entries,
                            selectedId: navigation.selectedCategoryId,
                            scrollController: _sidebarScrollController,
                            onSelected: (entry) {
                              final alreadySelected =
                                  navigation.selectedCategoryId == entry.id &&
                                  navigation.path.length == 1;
                              notifier.selectCategory(entry.id);
                              if (!alreadySelected) {
                                ref
                                    .read(analyticsProvider)
                                    .whenData(
                                      (a) => a?.logScreenView(entry.name),
                                    );
                              }
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (wide) const VerticalDivider(width: 1),
                  Expanded(
                    child: Navigator(
                      key: _contentNavigatorKey,
                      pages: _destinationPages(
                        context: context,
                        wide: wide,
                        navigation: navigation,
                        destinations: destinations,
                        entries: entries,
                        options: options,
                        notifier: notifier,
                        applicationNavigator: applicationNavigator,
                        closeHost: closeHost,
                      ),
                      onDidRemovePage: (page) {
                        final currentId = ref
                            .read(settingsNavigationProvider(_seed))
                            .currentDestinationId;
                        if (page.key == ValueKey('settings-$currentId')) {
                          notifier.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Page<void>> _destinationPages({
    required BuildContext context,
    required bool wide,
    required SettingsNavigationState navigation,
    required Map<String, SettingEntry> destinations,
    required List<SettingEntry> entries,
    required SettingsPageOptions options,
    required SettingsNavigationNotifier notifier,
    required NavigatorState applicationNavigator,
    required VoidCallback closeHost,
  }) {
    final reduceAnimations =
        MediaQuery.disableAnimationsOf(context) ||
        ref.watch(
          settingsProvider.select((settings) => settings.reduceAnimations),
        );
    final pages = <Page<void>>[
      _settingsPage(
        id: 'index',
        wide: wide,
        reduceAnimations: reduceAnimations,
        child: _SettingsDestinationFrame(
          title: context.t.settings.settings,
          onBack: closeHost,
          onClose: closeHost,
          child: _SettingsIndexContent(
            entries: entries,
            scrollController: _compactIndexScrollController,
            onSelected: (entry) {
              notifier.selectCategory(entry.id);
              ref
                  .read(analyticsProvider)
                  .whenData((a) => a?.logScreenView(entry.name));
            },
          ),
        ),
      ),
    ];

    for (var index = 0; index < navigation.path.length; index++) {
      final id = navigation.path[index];
      final entry = destinations[id];
      if (entry == null) continue;
      pages.add(
        _settingsPage(
          id: id,
          wide: wide,
          reduceAnimations: reduceAnimations,
          child: SettingsPageScope(
            options: options,
            child: SettingsPageNavigationScope(
              openContent: (_, nested) => notifier.openNested(nested.id),
              applicationNavigator: applicationNavigator,
              child: _SettingsDestinationFrame(
                title: entry.title,
                onBack: notifier.back,
                showBackInWide: index > 0,
                onClose: closeHost,
                child: entry.content,
              ),
            ),
          ),
        ),
      );
    }
    return pages;
  }

  Page<void> _settingsPage({
    required String id,
    required bool wide,
    required bool reduceAnimations,
    required Widget child,
  }) => SettingsAdaptivePage<void>(
    key: ValueKey('settings-$id'),
    name: id == 'index' ? '/settings/index' : '/settings/$id',
    animate: !wide && !reduceAnimations,
    child: child,
  );

  void _handleRequestedScroll({required bool wide}) {
    if (widget.scrollTo != 'support') return;
    final controller = wide
        ? _sidebarScrollController
        : _compactIndexScrollController;
    if (wide ? _sidebarScrollHandled : _compactScrollHandled) return;
    if (wide) {
      _sidebarScrollHandled = true;
    } else {
      _compactScrollHandled = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;
      controller.animateToWithAccessibility(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        reduceAnimations: ref.read(settingsProvider).reduceAnimations,
      );
    });
  }

  @override
  void dispose() {
    _compactIndexScrollController.dispose();
    _sidebarScrollController.dispose();
    super.dispose();
  }
}

class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar({
    required this.entries,
    required this.selectedId,
    required this.scrollController,
    required this.onSelected,
  });

  final List<SettingEntry> entries;
  final String? selectedId;
  final ScrollController scrollController;
  final ValueChanged<SettingEntry> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SettingsPaneHeader(title: context.t.settings.settings),
      const Divider(height: 1),
      Expanded(
        child: _SettingsNavigationList(
          key: const ValueKey('settings-sidebar-list'),
          storageKey: const PageStorageKey('settings-sidebar-scroll'),
          entries: entries,
          selectedId: selectedId,
          scrollController: scrollController,
          onSelected: onSelected,
        ),
      ),
    ],
  );
}

class _SettingsNavigationList extends StatelessWidget {
  const _SettingsNavigationList({
    required this.entries,
    required this.scrollController,
    required this.onSelected,
    required this.storageKey,
    this.selectedId,
    super.key,
  });

  final List<SettingEntry> entries;
  final String? selectedId;
  final ScrollController scrollController;
  final ValueChanged<SettingEntry> onSelected;
  final PageStorageKey<String> storageKey;

  @override
  Widget build(BuildContext context) => ListView(
    key: storageKey,
    controller: scrollController,
    padding: EdgeInsets.zero,
    children: [
      _SettingsSection(label: context.t.settings.app_settings),
      for (final entry in entries)
        SettingTile(
          title: entry.title,
          leading: SettingEntryIcon(icon: entry.icon),
          selected: selectedId == entry.id,
          onTap: () => onSelected(entry),
        ),
      const SettingsPageOtherSection(),
      const _Divider(),
      const _Footer(),
    ],
  );
}

class _SettingsDestinationFrame extends StatelessWidget {
  const _SettingsDestinationFrame({
    required this.title,
    required this.onBack,
    required this.onClose,
    required this.child,
    this.showBackInWide = false,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final Widget child;
  final bool showBackInWide;

  @override
  Widget build(BuildContext context) {
    final wide = _SettingsPresentationScope.of(context).wide;
    return Material(
      color: Kurumi.themeOf(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          _SettingsPaneHeader(
            title: title,
            leading: wide && !showBackInWide
                ? null
                : BackButton(onPressed: onBack),
            trailing: wide
                ? IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
          if (wide) const Divider(height: 1),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsIndexContent extends StatelessWidget {
  const _SettingsIndexContent({
    required this.entries,
    required this.scrollController,
    required this.onSelected,
  });

  final List<SettingEntry> entries;
  final ScrollController scrollController;
  final ValueChanged<SettingEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    if (_SettingsPresentationScope.of(context).wide) {
      return const _SettingsEmptyDetail();
    }
    return _SettingsNavigationList(
      key: const ValueKey('settings-compact-index-list'),
      storageKey: const PageStorageKey('settings-compact-index-scroll'),
      entries: entries,
      scrollController: scrollController,
      onSelected: onSelected,
    );
  }
}

class _SettingsPresentationScope extends InheritedWidget {
  const _SettingsPresentationScope({
    required this.wide,
    required super.child,
  });

  final bool wide;

  static _SettingsPresentationScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SettingsPresentationScope>()!;

  @override
  bool updateShouldNotify(_SettingsPresentationScope oldWidget) =>
      wide != oldWidget.wide;
}

class _SettingsPaneHeader extends StatelessWidget {
  const _SettingsPaneHeader({
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          SizedBox(width: 56, child: leading),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Kurumi.themeOf(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(width: 56, child: trailing),
        ],
      ),
    ),
  );
}

class _SettingsEmptyDetail extends StatelessWidget {
  const _SettingsEmptyDetail();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'Select a settings category',
      style: Kurumi.themeOf(context).textTheme.bodyLarge?.copyWith(
        color: Kurumi.themeOf(context).colorScheme.hintColor,
      ),
    ),
  );
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
                          launcher: ref.read(externalUrlLauncherProvider),
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
                context: SettingsPageNavigationScope.applicationNavigatorOf(
                  context,
                ).context,
                useRootNavigator: false,
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
          onTap: () =>
              SettingsPageNavigationScope.applicationNavigatorOf(
                context,
              ).push(
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
            launcher: ref.read(externalUrlLauncherProvider),
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
            launcher: ref.read(externalUrlLauncherProvider),
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
            launcher: ref.read(externalUrlLauncherProvider),
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
              launcher: ref.read(externalUrlLauncherProvider),
            ),
            icon: const FaIcon(FontAwesomeIcons.squareGithub),
          ),
          IconButton(
            onPressed: () => launchExternalUrl(
              Uri.parse(ref.read(appInfoProvider).discordUrl),
              launcher: ref.read(externalUrlLauncherProvider),
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
