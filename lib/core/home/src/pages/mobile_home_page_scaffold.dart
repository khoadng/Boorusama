// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../configs/ref.dart';
import '../../../posts/count/widgets.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/providers.dart';
import '../../../search/search/types.dart';
import '../../../search/selected_tags/providers.dart';
import '../../../settings/providers.dart';
import '../../../tags/metatag/providers.dart';
import '../../../widgets/widgets.dart';
import '../widgets/home_search_bar.dart';

class MobileHomePageScaffold extends ConsumerStatefulWidget {
  const MobileHomePageScaffold({
    super.key,
  });

  @override
  ConsumerState<MobileHomePageScaffold> createState() =>
      _MobileHomePageScaffoldState();
}

class _MobileHomePageScaffoldState
    extends ConsumerState<MobileHomePageScaffold> {
  final selectedTagString = ValueNotifier('');
  late final SelectedTagController selectedTagController;

  @override
  void initState() {
    super.initState();

    selectedTagController = SelectedTagController(
      metatagExtractor: ref.read(metatagExtractorProvider(ref.readConfigAuth)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    selectedTagString.dispose();
    selectedTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return PostScope(
      fetcher: (page) {
        return postRepo.getPostsFromController(
          selectedTagController.tagSet,
          page,
        );
      },
      builder: (context, postController) => Column(
        children: [
          Expanded(
            child: PostGrid(
              controller: postController,
              sliverHeaders: [
                if (context.isLargeScreen ||
                    searchBarPosition == SearchBarPosition.top)
                  SliverHomeSearchBar(
                    selectedTagController: selectedTagController,
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
          ),
          if (searchBarPosition == SearchBarPosition.bottom &&
              !context.isLargeScreen)
            Consumer(
              builder: (_, ref, _) {
                final position = ref.watch(
                  settingsProvider.select(
                    (value) => value.booruConfigSelectorPosition,
                  ),
                );

                return SafeArea(
                  top: false,
                  bottom: !position.isBottom,
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: CustomScrollView(
                      slivers: [
                        SliverHomeSearchBar(
                          primary: false,
                          selectedTagController: selectedTagController,
                          selectedTagString: selectedTagString,
                          onSearch: () {
                            postController.refresh();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
