// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../analytics/providers.dart';
import '../../../../boorus/booru/types.dart';
import '../../../../config_widgets/website_logo.dart';
import '../../../../posts/sources/types.dart';
import '../../../../premiums/providers.dart';
import '../../../../settings/routes.dart';
import '../../../../settings/types.dart' show SettingsSearchEntry;
import '../../../../settings/widgets.dart';
import '../../../appearance/widgets.dart';
import '../../../config/data.dart';
import '../../../config/types.dart';
import '../../../download/widgets.dart';
import '../../../gesture/widgets.dart';
import '../../../listing/widgets.dart';
import '../../../manage/providers.dart';
import '../../../network/widgets.dart';
import '../../../search/widgets.dart';
import '../../../viewer/widgets.dart';
import '../../widgets.dart';
import '../providers/providers.dart';
import '../types/edit_booru_config_id.dart';
import 'unsaved_alert_dialog.dart';

class CreateBooruConfigScaffold extends ConsumerStatefulWidget {
  const CreateBooruConfigScaffold({
    required this.initialTab,
    super.key,
    this.backgroundColor,
    this.authTab,
    this.searchTab,
    this.downloadTab,
    this.gestureTab,
    this.imageViewerTab,
    this.listingTab,
    this.layoutTab,
    this.networkTab,
    this.canSubmit,
    this.footer,
    this.version,
  });

  final Color? backgroundColor;

  final Widget? authTab;
  final Widget? searchTab;
  final Widget? downloadTab;
  final Widget? gestureTab;
  final Widget? imageViewerTab;
  final Widget? listingTab;
  final Widget? layoutTab;
  final Widget? networkTab;

  final String? initialTab;

  final Widget? footer;
  final Widget? version;

  final bool Function(BooruConfigData config)? canSubmit;
  @override
  ConsumerState<CreateBooruConfigScaffold> createState() =>
      _CreateBooruConfigScaffoldState();
}

class _CreateBooruConfigScaffoldState
    extends ConsumerState<CreateBooruConfigScaffold> {
  String? _searchTab;
  String? _searchTarget;
  var _searchRequest = 0;

  @override
  Widget build(BuildContext context) {
    final editId = ref.watch(editBooruConfigIdProvider);

    final tabMap = {
      CreateBooruConfigCategory.auth(context): ?widget.authTab,
      CreateBooruConfigCategory.listing(context):
          widget.listingTab ?? const DefaultBooruConfigListingView(),
      if (ref.watch(showPremiumFeatsProvider))
        CreateBooruConfigCategory.appearance(context):
            widget.layoutTab ?? const DefaultBooruConfigLayoutView(),
      CreateBooruConfigCategory.download(context):
          widget.downloadTab ?? const BooruConfigDownloadView(),
      CreateBooruConfigCategory.search(context):
          widget.searchTab ?? const DefaultBooruConfigSearchView(),
      CreateBooruConfigCategory.gestures(context):
          widget.gestureTab ?? const DefaultBooruConfigGesturesView(),
      CreateBooruConfigCategory.viewer(context):
          widget.imageViewerTab ?? const BooruConfigViewerView(),
      CreateBooruConfigCategory.network(context):
          widget.networkTab ?? const BooruConfigNetworkView(),
    };

    final revealRequest =
        _searchRequest + (SettingReveal.maybeOf(context)?.request ?? 0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= 700 &&
            InlineSettingsSearch.maybeOf(context) == null;
        void openProfileResult(SettingsSearchEntry result) {
          if (!mounted) return;
          setState(() {
            _searchTab = result.category.id;
            _searchTarget = result.target;
            _searchRequest++;
          });
        }

        return SettingReveal(
          target: _searchRequest == 0
              ? SettingReveal.maybeOf(context)?.target
              : _searchTarget,
          request: revealRequest,
          child: Scaffold(
            backgroundColor: widget.backgroundColor,
            appBar: AppBar(
              titleSpacing: 0,
              title: SelectedBooruChip(
                booruType: editId.booruType,
                url: editId.url,
                version: widget.version,
              ),
              actions: [
                if (!wide)
                  IconButton(
                    tooltip: context.t.settings_search.title,
                    icon: const Icon(Icons.search),
                    onPressed: () => openSettingsSearch(
                      context,
                      editingProfile: ref.read(initialBooruConfigProvider),
                      editingId: editId,
                      onOpenProfile: openProfileResult,
                    ),
                  ),
                CreateOrUpdateBooruConfigButton(canSubmit: widget.canSubmit),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const BooruConfigPopScope(),
                  const SizedBox(height: 8),
                  if (!wide) const BooruConfigNameField(),
                  Expanded(
                    child: _TabControllerProvider(
                      selectionRequest: revealRequest,
                      initialIndex: _findInitialIndexFromQuery(
                        _searchTab ?? widget.initialTab,
                        tabMap,
                      ),
                      tabMap: tabMap,
                      length: tabMap.length,
                      animationDuration:
                          Screen.of(context).size != ScreenSize.small
                          ? Duration.zero
                          : null,
                      builder: (controller) {
                        final content = Column(
                          children: [
                            if (wide) const BooruConfigNameField(),
                            const SizedBox(height: 4),
                            if (!wide)
                              TabBar(
                                controller: controller,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                isScrollable: true,
                                tabs: [
                                  for (final tab in tabMap.keys)
                                    Tab(text: tab.title),
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
                                      context
                                          .t
                                          .booru
                                          .new_profile_leave_as_empty_tips,
                                      style: Kurumi.themeOf(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Kurumi.themeOf(
                                              context,
                                            ).colorScheme.hintColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ?widget.footer,
                          ],
                        );
                        if (!wide) return content;
                        final entry = SettingEntry(
                          id: 'profile-editor',
                          title:
                              context.t.settings.booru_settings.booru_settings,
                          name: '/boorus/${editId.id}/update',
                          icon: Icons.settings,
                          content: content,
                        );
                        return SettingsSearchPage(
                          editingProfile: ref.watch(initialBooruConfigProvider),
                          editingId: editId,
                          initialEntry: entry,
                          onOpenProfile: openProfileResult,
                          navigationBuilder: (context, selected, select, _) =>
                              ListView(
                                children: [
                                  for (final tab in tabMap.keys)
                                    ListTile(
                                      title: Text(tab.title),
                                      selected:
                                          controller.index ==
                                          tabMap.keys.toList().indexOf(tab),
                                      onTap: () {
                                        setState(() {
                                          _searchTab = tab.id;
                                          _searchTarget = null;
                                          _searchRequest++;
                                        });
                                        select(entry);
                                      },
                                    ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CreateBooruConfigScope extends ConsumerWidget {
  const CreateBooruConfigScope({
    required this.config,
    required this.child,
    required this.id,
    super.key,
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

  CreateBooruConfigCategory.auth(BuildContext context)
    : title = context.t.booru.authentication.title,
      name = 'config/auth',
      id = 'auth';

  CreateBooruConfigCategory.listing(BuildContext context)
    : title = context.t.booru.listing.title,
      name = 'config/listing',
      id = 'listing';

  CreateBooruConfigCategory.download(BuildContext context)
    : title = context.t.booru.downloads.title,
      name = 'config/download',
      id = 'download';

  CreateBooruConfigCategory.search(BuildContext context)
    : title = context.t.booru.search.title,
      name = 'config/search',
      id = 'search';

  CreateBooruConfigCategory.gestures(BuildContext context)
    : title = context.t.booru.gestures.title,
      name = 'config/gestures',
      id = 'gestures';

  CreateBooruConfigCategory.viewer(BuildContext context)
    : title = context.t.settings.image_viewer.image_viewer,
      name = 'config/viewer',
      id = 'viewer';

  CreateBooruConfigCategory.network(BuildContext context)
    : title = context.t.booru.network.title,
      name = 'config/network',
      id = 'network';

  CreateBooruConfigCategory.appearance(BuildContext context)
    : title = context.t.booru.appearance.title,
      name = 'config/appearance',
      id = 'appearance';

  CreateBooruConfigCategory.misc(BuildContext context)
    : title = context.t.booru.misc,
      name = 'config/misc',
      id = 'misc';

  final String title;
  final String id;
  final String name;

  @override
  List<Object?> get props => [title, id];
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
    required this.builder,
    this.initialIndex,
    this.selectionRequest = 0,
  });

  final Map<CreateBooruConfigCategory, Widget> tabMap;
  final Duration? animationDuration;
  final int length;
  final int? initialIndex;
  final int selectionRequest;
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

  @override
  void didUpdateWidget(covariant _TabControllerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.initialIndex != oldWidget.initialIndex ||
            widget.selectionRequest != oldWidget.selectionRequest) &&
        widget.initialIndex != null) {
      _controller.index = widget.initialIndex!;
    }
  }

  void _onTabChanged() {
    if (_lastIndex != _controller.index) {
      _lastIndex = _controller.index;

      final item = widget.tabMap.keys.elementAtOrNull(_controller.index);

      if (item != null) {
        ref
            .read(analyticsProvider)
            .whenData(
              (a) => a?.logScreenView(item.name),
            );
      }
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller);
  }
}

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    required this.booruType,
    required this.url,
    this.version,
    super.key,
  });

  final BooruType booruType;
  final Widget? version;
  final String url;

  @override
  Widget build(BuildContext context) {
    final source = PostSource.from(url);

    return ListTile(
      minVerticalPadding: 0,
      horizontalTitleGap: 12,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      leading: ConfigAwareWebsiteLogo.fromBooruType(booruType, url),
      title: Text(
        source.whenWeb(
          (source) => source.uri.host,
          () => url,
        ),
        style: Kurumi.themeOf(context).textTheme.titleLarge,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              context.t.booru.using_status(booru: booruType.displayName),
            ),
          ),
          ?version,
        ],
      ),
    );
  }
}

class BooruConfigPopScope extends ConsumerWidget {
  const BooruConfigPopScope({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialData = ref
        .watch(initialBooruConfigProvider)
        .toBooruConfigData();
    final editId = ref.watch(editBooruConfigIdProvider);
    final configData = ref.watch(
      editBooruConfigProvider(editId),
    );
    final notifier = ref.watch(booruConfigProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (configData == initialData) {
          Navigator.of(context).pop();
        } else {
          showDialog(
            context: context,
            builder: (_) => UnsavedAlertDialog(
              onSave: () {
                notifier.addOrUpdate(
                  id: editId,
                  newConfig: configData,
                );
                Navigator.of(context).pop();
              },
              onDiscard: () {
                Navigator.of(context).pop();
              },
            ),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
