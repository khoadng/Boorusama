// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';

const kDefaultPreviewImageButtonAction = {
  '',
  null,
  kToggleBookmarkAction,
  kDownloadAction,
  kViewArtistAction,
};

class UpdateBooruConfigScope extends ConsumerWidget {
  const UpdateBooruConfigScope({
    super.key,
    required this.id,
    required this.child,
  });

  final EditBooruConfigId id;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(booruConfigProvider);
    final config = configs?.firstWhereOrNull((e) => e.id == id.id);

    if (config == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Config not found'),
        ),
      );
    }

    return ProviderScope(
      overrides: [
        editBooruConfigIdProvider.overrideWithValue(id),
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: child,
    );
  }
}

class CreateBooruConfigScope extends ConsumerWidget {
  const CreateBooruConfigScope({
    super.key,
    required this.config,
    required this.child,
    required this.id,
  });

  final EditBooruConfigId id;
  final BooruConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        editBooruConfigIdProvider.overrideWithValue(id),
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: child,
    );
  }
}

class CreateBooruConfigScaffold extends ConsumerWidget {
  const CreateBooruConfigScaffold({
    super.key,
    this.backgroundColor,
    this.authTab,
    this.searchTab,
    this.postDetailsResolution,
    this.hasDownloadTab = true,
    this.hasRatingFilter = false,
    this.miscOptions,
    this.postDetailsGestureActions = kDefaultGestureActions,
    this.postPreviewQuickActionButtonActions = kDefaultPreviewImageButtonAction,
    this.describePostDetailsAction,
    this.describePostPreviewQuickAction,
    this.submitButton,
    required this.initialTab,
    this.footer,
  });

  final Color? backgroundColor;

  final Widget? authTab;
  final Widget? searchTab;

  final Widget? postDetailsResolution;

  final bool hasDownloadTab;
  final bool hasRatingFilter;

  final List<Widget>? miscOptions;

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;

  final Widget? submitButton;

  final String? initialTab;

  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final editId = ref.watch(editBooruConfigIdProvider);

    final tabMap = {
      if (authTab != null)
        'booru.authentication': BooruConfigEntry(
          title: 'booru.authentication'.tr(),
          overview: BooruConfigOverviewCard(
            title: 'booru.authentication'.tr(),
            icon: Symbols.account_circle,
            child: BooruConfigDataProvider(
              builder: (data) => data.login.isNotEmpty
                  ? Text(data.login)
                  : const Text('Anonymous'),
            ),
          ),
          details: authTab!,
        ),
      'Listing': BooruConfigEntry(
        title: 'Listing',
        overview: BooruConfigOverviewCard(
          title: 'Listing',
          icon: Symbols.dashboard,
          child: BooruConfigDataProvider(
            builder: (data) => Text(
              data.listingTyped?.enable == true ? 'Custom' : 'Default',
            ),
          ),
        ),
        details: const BooruConfigListingView(),
      ),
      if (hasDownloadTab)
        'booru.download': BooruConfigEntry(
          title: 'booru.download'.tr(),
          overview: BooruConfigOverviewCard(
            title: 'booru.download'.tr(),
            icon: Symbols.download,
          ),
          details: BooruConfigDownloadView(config: config),
        ),
      'Search': BooruConfigEntry(
        title: 'Search'.tr(),
        overview: BooruConfigOverviewCard(
          title: 'Search'.tr(),
          icon: Symbols.search,
        ),
        details: searchTab ??
            BooruConfigSearchView(
              hasRatingFilter: hasRatingFilter,
              config: config,
            ),
      ),
      'booru.gestures': BooruConfigEntry(
        title: 'booru.gestures'.tr(),
        overview: BooruConfigOverviewCard(
          title: 'booru.gestures'.tr(),
          icon: Symbols.gesture,
        ),
        details: BooruConfigGesturesView(
          postDetailsGestureActions: postDetailsGestureActions,
          describePostDetailsAction: describePostDetailsAction,
        ),
      ),
      'booru.misc': BooruConfigEntry(
        title: 'booru.misc'.tr(),
        overview: BooruConfigOverviewCard(
          title: 'booru.misc'.tr(),
          icon: Symbols.settings,
        ),
        details: BooruConfigMiscView(
          postDetailsGestureActions: postDetailsGestureActions,
          postPreviewQuickActionButtonActions:
              postPreviewQuickActionButtonActions,
          describePostPreviewQuickAction: describePostPreviewQuickAction,
          describePostDetailsAction: describePostDetailsAction,
          postDetailsResolution: postDetailsResolution,
          miscOptions: miscOptions,
        ),
      ),
    };

    final submitBtn = submitButton ?? const DefaultBooruSubmitButton();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: SelectedBooruChip(
          booruType: editId.booruType,
          url: editId.url,
        ),
        actions: [
          editId.isNew ? submitBtn : const SizedBox.shrink(),
        ],
      ),
      body: SubConfigOpener(
        query: initialTab,
        config: config,
        editId: editId,
        tabMap: tabMap,
        child: SafeArea(
            child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const BooruConfigNameField(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: tabMap.length,
                      itemBuilder: (context, index) {
                        final tab = tabMap.values.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: tab,
                        );
                      },
                    ),
                  ),
                  if (editId.isNew)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Not sure? Leave it as it is, you can change it later.',
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.colorScheme.hintColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (footer != null) footer!,
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SaveReminderBanner(
                saveButton: submitBtn,
              ),
            ),
          ],
        )),
      ),
    );
  }
}

int _findInitialIndexFromQuery(
  String? query,
  Map<String, Widget> tabMap,
) {
  final q = query?.toLowerCase();

  if (q == null) {
    return 0;
  }

  final tabNames = tabMap.keys.toList();

  for (var i = 0; i < tabNames.length; i++) {
    final tabName = tabNames[i].toLowerCase();

    if (tabName.contains(q)) {
      return i;
    }
  }

  return 0;
}

class SubConfigOpener extends StatefulWidget {
  const SubConfigOpener({
    super.key,
    required this.child,
    this.query,
    required this.tabMap,
    required this.config,
    required this.editId,
  });

  final BooruConfig config;
  final EditBooruConfigId editId;
  final Widget child;
  final String? query;
  final Map<String, BooruConfigEntry> tabMap;

  @override
  State<SubConfigOpener> createState() => _SubConfigOpenerState();
}

class _SubConfigOpenerState extends State<SubConfigOpener> {
  late final initialQuery = widget.query;

  @override
  void initState() {
    super.initState();

    if (initialQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final index = _findInitialIndexFromQuery(
          initialQuery,
          widget.tabMap,
        );

        if (index >= 0) {
          final key = widget.tabMap.keys.elementAt(index);
          final details = widget.tabMap[key]?.details;
          final title = widget.tabMap[key]?.title;

          if (details == null || title == null) {
            return;
          }

          Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (context) => _Details(
                      config: widget.config,
                      editId: widget.editId,
                      title: title,
                      details: details,
                    )),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class SaveReminderBanner extends ConsumerWidget {
  const SaveReminderBanner({
    super.key,
    required this.saveButton,
  });

  final Widget saveButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);

    // Don't show the banner if it's a new config
    if (id.isNew) {
      return const SizedBox.shrink();
    }

    final data = ref.watch(editBooruConfigProvider(id));
    final initialData = ref.watch(initialBooruConfigProvider);

    final isDirty = data != initialData.toBooruConfigData();

    if (!isDirty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'You have unsaved changes!',
              style: TextStyle(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          saveButton,
        ],
      ),
    );
  }
}

class BooruConfigEntry extends ConsumerWidget {
  const BooruConfigEntry({
    super.key,
    required this.title,
    required this.overview,
    required this.details,
  });

  final String title;
  final Widget overview;
  final Widget details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final editId = ref.watch(editBooruConfigIdProvider);

    return Material(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => _Details(
                config: config,
                editId: editId,
                title: title,
                details: details,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          ),
          child: overview,
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.config,
    required this.editId,
    required this.title,
    required this.details,
  });

  final BooruConfig config;
  final EditBooruConfigId editId;
  final String title;
  final Widget details;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(config),
        editBooruConfigIdProvider.overrideWithValue(editId),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          child: details,
        ),
      ),
    );
  }
}

class BooruConfigOverviewCard extends ConsumerWidget {
  const BooruConfigOverviewCard({
    super.key,
    required this.title,
    this.icon,
    this.child,
  });

  final String title;
  final Widget? child;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            color: context.colorScheme.onSurfaceVariant.withAlpha(232),
            icon ?? Symbols.settings,
            fill: 1,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          if (child != null)
            DefaultTextStyle(
              style: TextStyle(
                color: context.colorScheme.hintColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: child!,
              ),
            ),
          Icon(
            Icons.arrow_forward_ios,
            color: context.colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _TabControllerProvider extends StatefulWidget {
  const _TabControllerProvider({
    required this.tabMap,
    required this.animationDuration,
    required this.length,
    this.initialIndex,
    required this.builder,
  });

  final Map<String, Widget> tabMap;
  final Duration? animationDuration;
  final int length;
  final int? initialIndex;
  final Widget Function(TabController controller) builder;

  @override
  State<_TabControllerProvider> createState() => _TabControllerProviderState();
}

class _TabControllerProviderState extends State<_TabControllerProvider>
    with SingleTickerProviderStateMixin {
  late final _controller = TabController(
    length: widget.length,
    vsync: this,
    animationDuration: widget.animationDuration,
    initialIndex: widget.initialIndex ?? 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }
}

class BooruConfigSettingsHeader extends StatelessWidget {
  const BooruConfigSettingsHeader({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
