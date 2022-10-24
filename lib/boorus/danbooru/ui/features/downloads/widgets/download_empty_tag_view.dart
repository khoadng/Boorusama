// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';

class DownloadEmptyTagView extends StatelessWidget {
  const DownloadEmptyTagView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SimpleTagSearchView(
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
    );
  }
}
