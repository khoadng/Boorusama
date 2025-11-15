// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../tags/_shared/tag_list_notifier.dart';
import '../../../../users/creator/providers.dart';
import '../../../../users/details/routes.dart';
import '../../../../users/details/types.dart';
import '../../../../users/user/providers.dart';
import '../../../post/types.dart';
import '../../providers.dart';

class DanbooruFileDetails extends ConsumerWidget {
  const DanbooruFileDetails({
    required this.post,
    super.key,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagDetails = ref.watch(
      danbooruTagListProvider(ref.watchConfigAuth),
    )[post.id];
    final userColor = DanbooruUserColor.of(context);

    return FileDetailsSection(
      post: post,
      rating: tagDetails != null ? tagDetails.rating : post.rating,
      uploader: switch (ref.watch(danbooruCreatorProvider(post.uploaderId))) {
        null => null,
        final uploader => UploaderFileDetailTile(
          uploaderName: uploader.name,
          onViewDetails: () => goToUserDetailsPage(
            ref,
            details: UserDetails.fromCreator(uploader),
          ),
          textStyle: TextStyle(
            color: userColor.fromLevel(uploader.level),
            fontSize: 14,
          ),
          onSearch: switch (ref.watch(danbooruUploaderQueryProvider(post))) {
            final query? => () => goToSearchPage(
              ref,
              tag: query.resolveTag(),
            ),
            _ => null,
          },
        ),
      },
      customDetails: [
        if (ref.watch(danbooruCreatorProvider(post.approverId))
            case final approver?)
          FileDetailTile(
            title: context.t.post.detail.approver,
            value: FileDetailsInWell(
              onTap: () => goToUserDetailsPage(
                ref,
                details: UserDetails.fromCreator(approver),
              ),
              child: Text(
                approver.name.replaceAll('_', ' '),
                maxLines: 1,
                style: TextStyle(
                  color: userColor.fromLevel(approver.level),
                  fontSize: 14,
                ),
              ),
            ),
            valueTrailing: FileDetailsActionIconButton(
              onTap: () =>
                  goToSearchPage(ref, tag: 'approver:${approver.name}'),
            ),
          ),
      ],
    );
  }
}
