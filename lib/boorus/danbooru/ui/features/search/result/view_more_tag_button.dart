// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/search/search.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/side_sheet.dart';
import 'related_tag_action_sheet.dart';

class ViewMoreTagButton extends StatelessWidget {
  const ViewMoreTagButton({
    super.key,
    required this.relatedTag,
  });

  final RelatedTag relatedTag;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).iconTheme.color,
        backgroundColor: Theme.of(context).cardColor,
        side: BorderSide(
          color: Theme.of(context).hintColor,
        ),
      ),
      onPressed: () {
        final bloc = context.read<SearchBloc>();
        final page = BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
          builder: (context, state) {
            return RelatedTagActionSheet(
              relatedTag: relatedTag,
              onOpenWiki: (tag) => launchWikiPage(
                state.booru.url,
                tag,
              ),
              onAddToSearch: (tag) =>
                  bloc.add(SearchRelatedTagSelected(tag: tag)),
            );
          },
        );
        if (Screen.of(context).size == ScreenSize.small) {
          showBarModalBottomSheet(
            context: context,
            builder: (context) => page,
          );
        } else {
          showSideSheetFromRight(
            width: 220,
            body: page,
            context: context,
          );
        }
      },
      child: const Text('tag.related.more').tr(),
    );
  }
}
