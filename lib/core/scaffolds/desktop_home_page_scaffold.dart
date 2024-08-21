// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/functional.dart';

class DesktopHomePageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const DesktopHomePageScaffold({
    super.key,
    this.listBuilder,
    this.persistentHeaderBuilder,
    required this.fetcher,
    this.selectedTagString,
    this.selectedTagController,
  });

  final PostsOrErrorCore<T> Function(int page, String tags) fetcher;

  final List<Widget> Function()? persistentHeaderBuilder;

  final Widget Function(
    PostGridController<T> controller,
    BooruError? errors,
    Widget searchBar,
  )? listBuilder;

  final ValueNotifier<String>? selectedTagString;

  final SelectedTagController? selectedTagController;

  @override
  ConsumerState<DesktopHomePageScaffold<T>> createState() =>
      _DesktopHomePageScaffoldState<T>();
}

class _DesktopHomePageScaffoldState<T extends Post>
    extends ConsumerState<DesktopHomePageScaffold<T>> {
  late final selectedTagController = widget.selectedTagController ??
      SelectedTagController.fromBooruBuilder(
        builder: ref.readBooruBuilder(ref.readConfig),
      );

  @override
  void dispose() {
    if (widget.selectedTagController == null) {
      selectedTagController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) =>
          widget.fetcher(page, selectedTagController.rawTagsString),
      builder: (context, controller, errors) => context.screenHeight < 450
          ? widget.listBuilder?.call(
                controller,
                errors,
                _buildSearchbar(controller),
              ) ??
              _buildList(
                controller,
                errors,
                children: [
                  SliverToBoxAdapter(
                    child: _buildSearchbar(controller),
                  ),
                ],
              )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchbar(controller),
                if (widget.persistentHeaderBuilder != null)
                  ...widget.persistentHeaderBuilder!(),
                Expanded(
                  child: _buildList(
                    controller,
                    errors,
                    children: [
                      SliverToBoxAdapter(
                        child: Row(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: selectedTagString,
                              builder: (context, value, _) =>
                                  ResultHeaderWithProvider(
                                selectedTags: value.split(' '),
                                onRefresh: (maintainPage) => controller.refresh(
                                  maintainPage: maintainPage,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildList(
    PostGridController<Post> controller,
    BooruError? errors, {
    required List<Widget> children,
  }) {
    return InfinitePostListScaffold(
      controller: controller,
      errors: errors,
      sliverHeaderBuilder: (context) => children,
    );
  }

  Widget _buildSearchbar(PostGridController<Post> controller) {
    return DesktopSearchbar(
      onSearch: () => _onSearch(controller),
      selectedTagController: selectedTagController,
    );
  }

  late var selectedTagString = widget.selectedTagString ?? ValueNotifier('');

  void _onSearch(
    PostGridController postController,
  ) {
    ref
        .read(searchHistoryProvider.notifier)
        .addHistory(selectedTagController.rawTagsString);
    selectedTagString.value = selectedTagController.rawTagsString;
    postController.refresh();
  }
}

class DefaultDesktopHomePage extends ConsumerWidget {
  const DefaultDesktopHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final fetcher = booruBuilder?.postFetcher;

    return DesktopHomePageScaffold(
      fetcher: (page, tags) =>
          fetcher?.call(page, tags) ?? TaskEither.of(<Post>[].toResult()),
    );
  }
}
