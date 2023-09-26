// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/boorus/core/widgets/desktop_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/result_header.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';

class DesktopHomePageScaffold extends ConsumerStatefulWidget {
  const DesktopHomePageScaffold({
    super.key,
  });

  @override
  ConsumerState<DesktopHomePageScaffold> createState() =>
      _DesktopHomePageScaffoldState();
}

class _DesktopHomePageScaffoldState
    extends ConsumerState<DesktopHomePageScaffold> {
  late final selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  @override
  void initState() {
    super.initState();
    ref.read(searchHistoryProvider.notifier).fetchHistories();
  }

  @override
  void dispose() {
    selectedTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(currentBooruConfigProvider);
    final booruBuilders = ref.watch(booruBuildersProvider);
    final fetcher = booruBuilders[config.booruType]?.call().postFetcher;

    return PostScope(
      fetcher: (page) =>
          fetcher?.call(page, selectedTagController.rawTagsString) ??
          TaskEither.of(<Post>[]),
      builder: (context, controller, errors) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesktopSearchbar(
            onSearch: () => _onSearch(controller),
            selectedTagController: selectedTagController,
          ),
          Expanded(
            child: InfinitePostListScaffold(
              errors: errors,
              controller: controller,
              sliverHeaderBuilder: (context) => [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: selectedTagString,
                        builder: (context, value, _) =>
                            ResultHeaderWithProvider(
                          selectedTags: value.split(' '),
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

  var selectedTagString = ValueNotifier('');

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
