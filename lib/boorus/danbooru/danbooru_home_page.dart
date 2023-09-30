// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/widgets/desktop_search_bar.dart';
import 'package:boorusama/core/widgets/result_header.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'widgets/search/related_tag_section.dart';

class DanbooruHomePage extends ConsumerStatefulWidget {
  const DanbooruHomePage({super.key});

  @override
  ConsumerState<DanbooruHomePage> createState() => _DanbooruHomePageState();
}

class _DanbooruHomePageState extends ConsumerState<DanbooruHomePage> {
  late final selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  @override
  void initState() {
    super.initState();
    final config = ref.readConfig;
    ref.read(searchHistoryProvider.notifier).fetchHistories();
    ref.read(postCountStateProvider(config).notifier).getPostCount([]);
    ref.read(danbooruRelatedTagsProvider(config).notifier).fetch('');
  }

  @override
  void dispose() {
    selectedTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return DanbooruPostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider(config)).getPosts(
            selectedTagController.rawTags,
            page,
          ),
      builder: (context, controller, errors) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesktopSearchbar(
            onSearch: () => _onSearch(controller),
            selectedTagController: selectedTagController,
          ),
          ValueListenableBuilder(
            valueListenable: selectedTagString,
            builder: (context, value, _) => Material(
              color: context.theme.scaffoldBackgroundColor,
              child: RelatedTagSection(
                backgroundColor: Colors.transparent,
                query: value,
                onSelected: (tag) => selectedTagController.addTag(tag.tag),
              ),
            ),
          ),
          Expanded(
            child: DanbooruInfinitePostList(
              controller: controller,
              errors: errors,
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
        .read(danbooruRelatedTagsProvider(ref.readConfig).notifier)
        .fetch(selectedTagController.rawTagsString);
    ref
        .read(postCountStateProvider(ref.readConfig).notifier)
        .getPostCount(selectedTagController.rawTags);
    ref
        .read(searchHistoryProvider.notifier)
        .addHistory(selectedTagController.rawTagsString);
    selectedTagString.value = selectedTagController.rawTagsString;
    postController.refresh();
  }
}
