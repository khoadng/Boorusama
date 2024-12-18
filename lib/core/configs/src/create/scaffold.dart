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
import '../data/booru_config_data.dart';
import '../edit_booru_config_id.dart';
import 'download.dart';
import 'gestures.dart';
import 'listing.dart';
import 'providers.dart';
import 'riverpod_widgets.dart';
import 'search.dart';
import 'viewer.dart';

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
    this.downloadTab,
    this.gestureTab,
    this.imageViewerTab,
    this.listingTab,
    this.canSubmit,
    required this.initialTab,
    this.footer,
  });

  final Color? backgroundColor;

  final Widget? authTab;
  final Widget? searchTab;
  final Widget? downloadTab;
  final Widget? gestureTab;
  final Widget? imageViewerTab;
  final Widget? listingTab;

  final String? initialTab;

  final Widget? footer;

  final bool Function(BooruConfigData config)? canSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);

    final tabMap = {
      if (authTab != null) 'booru.authentication': authTab!,
      'Listing': listingTab ?? const DefaultBooruConfigListingView(),
      'booru.download': downloadTab ?? const BooruConfigDownloadView(),
      'Search': searchTab ?? const DefaultBooruConfigSearchView(),
      'booru.gestures': gestureTab ?? const DefaultBooruConfigGesturesView(),
      'settings.image_viewer.image_viewer':
          imageViewerTab ?? const BooruConfigViewerView(),
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

class SelectedBooruChip extends StatelessWidget {
  const SelectedBooruChip({
    super.key,
    required this.booruType,
    required this.url,
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
