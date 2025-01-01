// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../foundation/display.dart';
import '../../../posts/sources/source.dart';
import '../../../theme.dart';
import '../../../widgets/widgets.dart';
import '../booru_config.dart';
import '../booru_config_converter.dart';
import '../data/booru_config_data.dart';
import '../edit_booru_config_id.dart';
import '../manage/booru_config_provider.dart';
import 'appearance.dart';
import 'download.dart';
import 'gestures.dart';
import 'listing.dart';
import 'network.dart';
import 'providers.dart';
import 'riverpod_widgets.dart';
import 'search.dart';
import 'unsaved_alert_dialog.dart';
import 'viewer.dart';

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

class CreateBooruConfigScaffold extends ConsumerWidget {
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

  final bool Function(BooruConfigData config)? canSubmit;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);

    final tabMap = {
      if (authTab != null) 'booru.authentication': authTab!,
      'Listing': listingTab ?? const DefaultBooruConfigListingView(),
      'settings.appearance.appearance':
          layoutTab ?? const DefaultBooruConfigLayoutView(),
      'booru.download': downloadTab ?? const BooruConfigDownloadView(),
      'Search': searchTab ?? const DefaultBooruConfigSearchView(),
      'booru.gestures': gestureTab ?? const DefaultBooruConfigGesturesView(),
      'settings.image_viewer.image_viewer':
          imageViewerTab ?? const BooruConfigViewerView(),
      'Network': networkTab ?? const BooruConfigNetworkView(),
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
            const BooruConfigPopScope(),
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
                        for (final tab in tabMap.keys) Tab(text: tab.tr()),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.hintColor,
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

class _TabControllerProvider extends StatefulWidget {
  const _TabControllerProvider({
    required this.tabMap,
    required this.animationDuration,
    required this.length,
    required this.builder,
    this.initialIndex,
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

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    required this.booruType,
    required this.url,
    super.key,
  });

  final BooruType booruType;
  final String url;

  @override
  Widget build(BuildContext context) {
    final source = PostSource.from(url);

    return ListTile(
      minVerticalPadding: 0,
      horizontalTitleGap: 12,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      leading: BooruLogo.fromBooruType(booruType, url),
      title: Text(
        source.whenWeb(
          (source) => source.uri.host,
          () => url,
        ),
        style: Theme.of(context).textTheme.titleLarge,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('using ${booruType.stringify()}'),
    );
  }
}

class BooruConfigPopScope extends ConsumerWidget {
  const BooruConfigPopScope({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialData =
        ref.watch(initialBooruConfigProvider).toBooruConfigData();
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
