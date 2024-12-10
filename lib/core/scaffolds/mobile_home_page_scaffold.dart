// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../boorus/booru_builder.dart';
import '../../boorus/providers.dart';
import '../../foundation/display.dart';
import '../configs/ref.dart';
import '../home/home_page_controller.dart';
import '../home/home_search_bar.dart';
import '../posts/count/widgets.dart';
import '../posts/listing/widgets.dart';
import '../search/selected_tags.dart';
import '../tags/configs/providers.dart';
import '../widgets/widgets.dart';

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
