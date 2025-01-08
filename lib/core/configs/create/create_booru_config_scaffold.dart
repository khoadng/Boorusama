// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import '../../../foundation/analytics.dart';

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
    final config = configs.firstWhereOrNull((e) => e.id == id.id);

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

class CreateBooruConfigCategory extends Equatable {
  const CreateBooruConfigCategory({
    required this.id,
    required this.name,
    required this.title,
  });

  const CreateBooruConfigCategory.auth()
      : title = 'booru.authentication',
        name = 'config/auth',
        id = 'auth';

  const CreateBooruConfigCategory.listing()
      : title = 'Listing',
        name = 'config/listing',
        id = 'listing';

  const CreateBooruConfigCategory.download()
      : title = 'booru.download',
        name = 'config/download',
        id = 'download';

  const CreateBooruConfigCategory.search()
      : title = 'Search',
        name = 'config/search',
        id = 'search';

  const CreateBooruConfigCategory.gestures()
      : title = 'booru.gestures',
        name = 'config/gestures',
        id = 'gestures';

  const CreateBooruConfigCategory.misc()
      : title = 'booru.misc',
        name = 'config/misc',
        id = 'misc';

  final String title;
  final String id;
  final String name;

  @override
  List<Object?> get props => [title, id];
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
    this.canSubmit,
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

  final String? initialTab;

  final Widget? footer;

  final bool Function(BooruConfigData config)? canSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final editId = ref.watch(editBooruConfigIdProvider);

    final tabMap = {
      if (authTab != null) CreateBooruConfigCategory.auth(): authTab!,
      CreateBooruConfigCategory.listing(): const BooruConfigListingView(),
      if (hasDownloadTab)
        CreateBooruConfigCategory.download():
            BooruConfigDownloadView(config: config),
      CreateBooruConfigCategory.search(): searchTab ??
          BooruConfigSearchView(
            hasRatingFilter: hasRatingFilter,
            config: config,
          ),
      CreateBooruConfigCategory.gestures(): BooruConfigGesturesView(
        postDetailsGestureActions: postDetailsGestureActions,
        describePostDetailsAction: describePostDetailsAction,
      ),
      CreateBooruConfigCategory.misc(): BooruConfigMiscView(
        postDetailsGestureActions: postDetailsGestureActions,
        postPreviewQuickActionButtonActions:
            postPreviewQuickActionButtonActions,
        describePostPreviewQuickAction: describePostPreviewQuickAction,
        describePostDetailsAction: describePostDetailsAction,
        postDetailsResolution: postDetailsResolution,
        miscOptions: miscOptions,
      ),
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: SelectedBooruChip(
          booruType: editId.booruType,
          url: editId.url,
        ),
        actions: [
          CreateOrUpdateBooruConfigButton(canSubmit: canSubmit),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const BooruConfigNameField(),
            Expanded(
              child: _TabControllerProvider(
                initialIndex: _findInitialIndexFromQuery(
                  initialTab,
                  tabMap,
                ),
                tabMap: tabMap,
                length: tabMap.length,
                animationDuration:
                    Screen.of(context).size.isLarge ? Duration.zero : null,
                builder: (controller) => Column(
                  children: [
                    const SizedBox(height: 4),
                    TabBar(
                      controller: controller,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      isScrollable: true,
                      tabs: [
                        for (final tab in tabMap.keys)
                          Tab(text: tab.title.tr()),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 700,
                        ),
                        child: TabBarView(
                          controller: controller,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (final tab in tabMap.values) tab,
                          ],
                        ),
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
                                color: context.theme.hintColor,
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
            ),
          ],
        ),
      ),
    );
  }
}

int _findInitialIndexFromQuery(
  String? query,
  Map<CreateBooruConfigCategory, Widget> tabMap,
) {
  final q = query?.toLowerCase();

  if (q == null) {
    return 0;
  }

  final tabNames = tabMap.keys.toList();

  for (var i = 0; i < tabNames.length; i++) {
    final tabName = tabNames[i].id.toLowerCase();

    if (tabName.contains(q)) {
      return i;
    }
  }

  return 0;
}

class _TabControllerProvider extends ConsumerStatefulWidget {
  const _TabControllerProvider({
    required this.tabMap,
    required this.animationDuration,
    required this.length,
    this.initialIndex,
    required this.builder,
  });

  final Map<CreateBooruConfigCategory, Widget> tabMap;
  final Duration? animationDuration;
  final int length;
  final int? initialIndex;
  final Widget Function(TabController controller) builder;

  @override
  ConsumerState<_TabControllerProvider> createState() =>
      _TabControllerProviderState();
}

class _TabControllerProviderState extends ConsumerState<_TabControllerProvider>
    with SingleTickerProviderStateMixin {
  late final _controller = TabController(
    length: widget.length,
    vsync: this,
    animationDuration: widget.animationDuration,
    initialIndex: widget.initialIndex ?? 0,
  );

  int? _lastIndex;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTabChanged);

    _onTabChanged();
  }

  void _onTabChanged() {
    if (_lastIndex != _controller.index) {
      _lastIndex = _controller.index;

      final item = widget.tabMap.keys.elementAtOrNull(_controller.index);

      if (item != null) {
        ref.read(analyticsProvider).logScreenView(item.name);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
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
