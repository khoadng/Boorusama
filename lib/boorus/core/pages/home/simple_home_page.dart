// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/desktop_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/posts/simple_infinite_post_list.dart';
import 'package:boorusama/boorus/core/widgets/result_header.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';

class SimpleHomePage extends ConsumerStatefulWidget {
  const SimpleHomePage({
    super.key,
  });

  @override
  ConsumerState<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends ConsumerState<SimpleHomePage> {
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
    return PostScope(
      fetcher: (page) => ref.watch(postRepoProvider).getPostsFromTags(
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
            child: SimpleInfinitePostList(
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