// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/e621_post_provider.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/search/search.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class E621DesktopHomePage extends ConsumerStatefulWidget {
  const E621DesktopHomePage({
    super.key,
  });

  @override
  ConsumerState<E621DesktopHomePage> createState() =>
      _E621DesktopHomePageState();
}

class _E621DesktopHomePageState extends ConsumerState<E621DesktopHomePage> {
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
      fetcher: (page) => ref.read(e621PostRepoProvider(config)).getPosts(
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
          Expanded(
            child: InfinitePostListScaffold(
              controller: controller,
              errors: errors,
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
