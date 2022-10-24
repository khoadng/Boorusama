// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';

class DownloadEmptyTagView extends StatelessWidget {
  const DownloadEmptyTagView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: SearchBar(
            enabled: false,
            hintText: 'Add tag',
            onTap: () {
              final bloc = context.read<BulkImageDownloadBloc>();
              showBarModalBottomSheet(
                context: context,
                builder: (context) => SimpleTagSearchView(
                  ensureValidTag: false,
                  onSelected: (tag) {
                    bloc.add(
                      BulkImageDownloadTagsAdded(
                        tags: [tag.value],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Center(
          child: Text(
            'No tags selected',
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
