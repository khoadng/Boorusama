// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/home/home_page_controller.dart';
import 'package:boorusama/core/home/home_search_bar.dart';
import 'package:boorusama/core/posts/count/widgets.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/search/selected_tags.dart';
import 'package:boorusama/core/tags/configs/providers.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';

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
  late final selectedTagController = SelectedTagController.fromBooruBuilder(
    builder: ref.read(currentBooruBuilderProvider),
    tagInfo: ref.read(tagInfoProvider),
  );

  @override
  void dispose() {
    super.dispose();
    selectedTagString.dispose();
    selectedTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return PostScope(
      fetcher: (page) {
        return postRepo.getPostsFromController(selectedTagController, page);
      },
      builder: (context, postController) => PostGrid(
        controller: postController,
        sliverHeaders: [
          SliverHomeSearchBar(
            selectedTagController: selectedTagController,
            controller: widget.controller,
            selectedTagString: selectedTagString,
            onSearch: () {
              postController.refresh();
            },
          ),
          const SliverAppAnnouncementBanner(),
          if (context.isLargeScreen)
            SliverResultHeader(
              selectedTagString: selectedTagString,
              controller: postController,
            ),
        ],
      ),
    );
  }
}
