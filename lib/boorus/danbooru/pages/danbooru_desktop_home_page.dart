// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/search/related_tag_section.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class DanbooruDesktopHomePage extends ConsumerStatefulWidget {
  const DanbooruDesktopHomePage({super.key});

  @override
  ConsumerState<DanbooruDesktopHomePage> createState() =>
      _DanbooruHomePageState();
}

class _DanbooruHomePageState extends ConsumerState<DanbooruDesktopHomePage> {
  late final selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  @override
  void dispose() {
    selectedTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    return PostScope(
      fetcher: (page) => ref.read(danbooruPostRepoProvider(config)).getPosts(
            selectedTagController.rawTagsString,
            page,
          ),
      builder: (context, controller, errors) => context.screenHeight < 450
          ? _buildList(
              controller,
              errors,
              children: [
                SliverToBoxAdapter(
                  child: _buildSearchbar(controller),
                ),
                SliverToBoxAdapter(
                  child: _buildRelatedTags(),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchbar(controller),
                _buildRelatedTags(),
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
                                onRefresh: () => controller.refresh(),
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
    PostGridController<DanbooruPost> controller,
    BooruError? errors, {
    required List<Widget> children,
  }) {
    return DanbooruInfinitePostList(
      controller: controller,
      errors: errors,
      sliverHeaders: children,
    );
  }

  Widget _buildRelatedTags() {
    return ValueListenableBuilder(
      valueListenable: selectedTagString,
      builder: (context, value, _) => Material(
        color: context.theme.scaffoldBackgroundColor,
        child: RelatedTagSection(
          backgroundColor: Colors.transparent,
          query: value,
          onAdded: (tag) => selectedTagController.addTag(tag.tag),
          onNegated: (tag) => selectedTagController.negateTag(tag.tag),
        ),
      ),
    );
  }

  Widget _buildSearchbar(PostGridController<DanbooruPost> controller) {
    return DesktopSearchbar(
      onSearch: () => _onSearch(controller),
      selectedTagController: selectedTagController,
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
