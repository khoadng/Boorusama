// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru_v2/posts/posts_v2.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/search_histories/search_histories.dart';

class GelbooruV2DesktopHomePage extends ConsumerStatefulWidget {
  const GelbooruV2DesktopHomePage({
    super.key,
  });

  @override
  ConsumerState<GelbooruV2DesktopHomePage> createState() =>
      _GelbooruV2DesktopHomePageState();
}

class _GelbooruV2DesktopHomePageState
    extends ConsumerState<GelbooruV2DesktopHomePage> {
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.readBooruBuilder(ref.readConfig),
  );

  @override
  void dispose() {
    selectedTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.readConfig;

    return PostScope(
      fetcher: (page) => ref.watch(gelbooruV2PostRepoProvider(config)).getPosts(
            selectedTagController.rawTagsString,
            page,
          ),
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
