// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/search/search.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/desktop_search_bar.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';

class LocalbooruHomePage extends ConsumerStatefulWidget {
  const LocalbooruHomePage({
    super.key,
  });

  @override
  ConsumerState<LocalbooruHomePage> createState() => _LocalbooruHomePageState();
}

class _LocalbooruHomePageState extends ConsumerState<LocalbooruHomePage> {
  late final selectedTagController =
      SelectedTagController(tagInfo: ref.read(tagInfoProvider));

  var items = <String>[];

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
            child: CustomScrollView(
              slivers: [
                SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) => Image.file(
                      File(controller.items[index].thumbnailImageUrl)),
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
