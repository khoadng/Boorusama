// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import '../feats/posts/posts.dart';

class MoebooruDesktopHomePage extends ConsumerStatefulWidget {
  const MoebooruDesktopHomePage({
    super.key,
  });

  @override
  ConsumerState<MoebooruDesktopHomePage> createState() =>
      _MoebooruDesktopHomePageState();
}

class _MoebooruDesktopHomePageState
    extends ConsumerState<MoebooruDesktopHomePage> {
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
      fetcher: (page) => ref.watch(moebooruPostRepoProvider(config)).getPosts(
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
