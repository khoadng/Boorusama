// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/search/simple_tag_search_view.dart';

class DownloadEmptyTagView extends ConsumerWidget {
  const DownloadEmptyTagView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SimpleTagSearchView(
          backButton: IconButton(
            splashRadius: 16,
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.arrow_back),
          ),
          textColorBuilder: (tag) => generateDanbooruAutocompleteTagColor(
              tag, theme), //FIXME: should be a provider
          closeOnSelected: false,
          ensureValidTag: false,
          onSelected: (tag) {
            ref
                .read(bulkDownloadSelectedTagsProvider.notifier)
                .addTag(tag.value);
          },
        ),
      ),
    );
  }
}
