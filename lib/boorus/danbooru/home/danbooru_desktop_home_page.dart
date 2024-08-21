// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/related_tags/related_tag_section.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/foundation/theme.dart';

class DanbooruDesktopHomePage extends ConsumerStatefulWidget {
  const DanbooruDesktopHomePage({super.key});

  @override
  ConsumerState<DanbooruDesktopHomePage> createState() =>
      _DanbooruHomePageState();
}

class _DanbooruHomePageState extends ConsumerState<DanbooruDesktopHomePage> {
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
    final config = ref.watchConfig;
    final postRepo = ref.watch(danbooruPostRepoProvider(config));

    return DesktopHomePageScaffold(
      fetcher: (page, tags) => postRepo.getPosts(tags, page),
      selectedTagController: selectedTagController,
      selectedTagString: selectedTagString,
      persistentHeaderBuilder: () => [
        _buildRelatedTags(),
      ],
      listBuilder: (controller, errors, searchBar) => DanbooruInfinitePostList(
        controller: controller,
        errors: errors,
        sliverHeaders: [
          SliverToBoxAdapter(
            child: searchBar,
          ),
          SliverToBoxAdapter(
            child: _buildRelatedTags(),
          ),
        ],
      ),
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

  var selectedTagString = ValueNotifier('');
}
