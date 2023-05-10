// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/ui/search/simple_tag_search_view.dart';

class DownloadEmptyTagView extends StatelessWidget {
  const DownloadEmptyTagView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SimpleTagSearchView(
          textColorBuilder: (tag) =>
              generateDanbooruAutocompleteTagColor(tag, theme),
          closeOnSelected: false,
          ensureValidTag: false,
          onSelected: (tag) {
            context.read<BulkDownloadManagerBloc>().add(
                  BulkDownloadManagerTagsAdded(
                    tags: [tag.value],
                  ),
                );
          },
        ),
      ),
    );
  }
}
