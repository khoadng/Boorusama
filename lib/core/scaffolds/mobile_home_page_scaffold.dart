// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/home/home.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/functional.dart';

class MobileHomePageScaffold extends ConsumerStatefulWidget {
  const MobileHomePageScaffold({
    super.key,
    required this.controller,
    required this.onSearchTap,
  });

  final HomePageController controller;
  final void Function() onSearchTap;

  @override
  ConsumerState<MobileHomePageScaffold> createState() =>
      _MobileHomePageScaffoldState();
}

class _MobileHomePageScaffoldState
    extends ConsumerState<MobileHomePageScaffold> {
  final selectedTagString = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final fetcher = booruBuilder?.postFetcher;

    return PostScope(
      fetcher: (page) =>
          fetcher?.call(page, '') ?? TaskEither.of(<Post>[].toResult()),
      builder: (context, postController, errors) => InfinitePostListScaffold(
        errors: errors,
        controller: postController,
        sliverHeaders: [
          SliverHomeSearchBar(
            controller: widget.controller,
            selectedTagString: selectedTagString,
            onSearch: () {
              postController.refresh();
            },
          ),
          const SliverAppAnnouncementBanner(),
          if (context.isLandscapeLayout)
            SliverResultHeader(
              selectedTagString: selectedTagString,
              controller: postController,
            ),
        ],
      ),
    );
  }
}
