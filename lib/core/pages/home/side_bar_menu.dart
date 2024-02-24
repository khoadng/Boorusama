// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'side_menu_tile.dart';

class SideBarMenu extends ConsumerWidget {
  const SideBarMenu({
    super.key,
    this.width,
    this.popOnSelect = false,
    this.initialContentBuilder,
    this.contentBuilder,
    this.padding,
  });

  final double? width;
  final EdgeInsets? padding;
  final bool popOnSelect;
  final List<Widget>? Function(BuildContext context)? initialContentBuilder;
  final List<Widget> Function(BuildContext context)? contentBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: context.colorScheme.surface,
      constraints:
          BoxConstraints.expand(width: min(context.screenWidth * 0.85, 500)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: context.colorScheme.secondaryContainer,
            child: const SafeArea(
              bottom: false,
              child: BooruSelector(),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: context.colorScheme.surface,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.viewPaddingOf(context).top,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: CurrentBooruTile(),
                    ),
                    if (initialContentBuilder != null)
                      ...[
                        ...initialContentBuilder!(context)!,
                      ].map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          )),
                    const Divider(),
                    if (contentBuilder != null) ...[
                      ...contentBuilder!(context).map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          ))
                    ] else
                      ...[
                        SideMenuTile(
                          icon: const Icon(Symbols.favorite),
                          title: const Text('sideMenu.your_bookmarks').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/bookmarks');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.list),
                          title: const Text('sideMenu.your_blacklist').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/global_blacklisted_tags');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.tag),
                          title: const Text('Favorite tags'),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/favorite_tags');
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.search),
                          title: const Text('Multi-Search'),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.navigator.push(CupertinoPageRoute(
                              builder: (context) => const MultiSearchPage(),
                            ));
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(Symbols.download),
                          title: const Text('sideMenu.bulk_download').tr(),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            goToBulkDownloadPage(
                              context,
                              null,
                              ref: ref,
                            );
                          },
                        ),
                        SideMenuTile(
                          icon: const Icon(
                            Symbols.settings,
                            fill: 1,
                          ),
                          title: Text('sideMenu.settings'.tr()),
                          onTap: () {
                            if (popOnSelect) context.navigator.pop();
                            context.go('/settings');
                          },
                        ),
                      ].map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _currentTabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class MultiSearchPage extends ConsumerStatefulWidget {
  const MultiSearchPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MultiSearchPageState();
}

class _MultiSearchPageState extends ConsumerState<MultiSearchPage> {
  var _selectedTags = <String>[];
  var textController = TextEditingController();
  late ValueKey _key = ValueKey(_selectedTags);

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(booruConfigProvider);
    final seen = <BooruType>{};
    final configsSafe = <BooruConfig>[];

    for (final config in configs ?? <BooruConfig>[]) {
      if (seen.contains(config.booruType)) continue;
      seen.add(config.booruType);
      configsSafe.add(config);
    }

    final tabMap = {
      for (final config in configsSafe)
        (config.name, config.id): _buildTab(context, config),
    };

    return Material(
      child: SafeArea(
        child: Column(
          children: [
            BooruSearchBar(
              queryEditingController: textController,
              trailing: IconButton(
                icon: const Icon(Symbols.search),
                onPressed: () {
                  setState(() {
                    _selectedTags = textController.text
                        .split(' ')
                        .where((e) => e.isNotEmpty)
                        .toList();
                    _key = ValueKey(_selectedTags);
                  });
                },
              ),
            ),
            Expanded(
              child: DefaultTabController(
                animationDuration: const Duration(milliseconds: 50),
                length: tabMap.length,
                child: Builder(
                  builder: (context) {
                    final controller = DefaultTabController.of(context);
                    controller.addListener(() {
                      if (!controller.indexIsChanging) {
                        ref.read(_currentTabIndexProvider.notifier).state =
                            controller.index;
                      }
                    });
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        TabBar(
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          indicatorColor: context.colorScheme.onBackground,
                          labelColor: context.colorScheme.onBackground,
                          unselectedLabelColor:
                              context.colorScheme.onBackground.withOpacity(0.5),
                          tabs: [
                            for (final tab in tabMap.keys)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tab.$1),
                                    const SizedBox(width: 8),
                                    ref.watch(_isRefreshingProvider(tab.$2))
                                        ? const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: IndexedStack(
                              key: _key,
                              index: ref.watch(_currentTabIndexProvider),
                              children: [
                                for (final tab in tabMap.values) tab,
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, BooruConfig config) {
    return MultiSearchTabView(
      config: config,
      tags: _selectedTags,
    );
  }
}

class MultiSearchTabView extends ConsumerStatefulWidget {
  const MultiSearchTabView({
    super.key,
    required this.config,
    this.tags = const [],
  });

  final BooruConfig config;
  final List<String> tags;

  @override
  ConsumerState<MultiSearchTabView> createState() => _MultiSearchTabViewState();
}

class _MultiSearchTabViewState extends ConsumerState<MultiSearchTabView> {
  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) {
        final tags = widget.tags;

        print('tags: $tags');

        return tags.isNotEmpty
            ? ref.read(postRepoProvider(widget.config)).getPosts(tags, page)
            : TaskEither.right(<Post>[]);
      },
      builder: (context, controller, errors) => PostControllerStateListener(
        id: widget.config.id,
        controller: controller,
        child: InfinitePostListScaffold(
          initialConfig: widget.config,
          controller: controller,
          errors: errors,
        ),
      ),
    );
  }
}

final _isRefreshingProvider =
    StateProvider.autoDispose.family<bool, int>((ref, id) => false);

class PostControllerStateListener<T> extends ConsumerStatefulWidget {
  const PostControllerStateListener(
      {super.key,
      required this.child,
      required this.controller,
      required this.id});

  final int id;
  final Widget child;
  final PostGridController<T> controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostControllerStateListenerState<T>();
}

class _PostControllerStateListenerState<T>
    extends ConsumerState<PostControllerStateListener<T>> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_listener);
  }

  void _listener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.controller.refreshing) {
        ref.read(_isRefreshingProvider(widget.id).notifier).state = true;
      } else {
        ref.read(_isRefreshingProvider(widget.id).notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
