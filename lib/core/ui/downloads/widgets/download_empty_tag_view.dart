// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/utils.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/search/simple_tag_search_view.dart';
import 'package:boorusama/core/ui/warning_container.dart';

const _message =
    'Please be aware that since you are currently using the experimental download method, bulk download may not function as expected. This is because bulk download relies on the primary download method, and if the primary method is not working properly, bulk download will also not work.';

class DownloadEmptyTagView extends StatelessWidget {
  const DownloadEmptyTagView({
    super.key,
    required this.settings,
  });

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            if (settings.downloadMethod != DownloadMethod.flutterDownloader)
              WarningContainer(
                contentBuilder: (context) => const ReadMoreText(
                  _message,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  moreStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: SimpleTagSearchView(
                textColorBuilder: (tag) =>
                    generateDanbooruAutocompleteTagColor(tag, theme),
                closeOnSelected: false,
                ensureValidTag: false,
                onSelected: (tag) {
                  context.read<BulkImageDownloadBloc>().add(
                        BulkImageDownloadTagsAdded(
                          tags: [tag.value],
                        ),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
