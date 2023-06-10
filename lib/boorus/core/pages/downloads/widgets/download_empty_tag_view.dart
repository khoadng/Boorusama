// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/bulk_download_provider.dart';
import 'package:boorusama/boorus/core/feats/utils.dart';
import 'package:boorusama/boorus/core/pages/search/simple_tag_search_view.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/flutter.dart';

class DownloadEmptyTagView extends ConsumerWidget {
  const DownloadEmptyTagView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: context.theme.cardColor,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SimpleTagSearchView(
          backButton: IconButton(
            splashRadius: 16,
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.arrow_back),
          ),
          textColorBuilder: (tag) => generateAutocompleteTagColor(tag, theme),
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
