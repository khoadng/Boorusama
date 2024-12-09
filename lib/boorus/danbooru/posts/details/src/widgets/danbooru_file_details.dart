// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts/details/parts.dart';
import '../../../../router.dart';
import '../../../../tags/shared/tag_list_notifier.dart';
import '../../../../users/creator/creator.dart';
import '../../../../users/creator/creators_notifier.dart';
import '../../../post/post.dart';

class DanbooruFileDetails extends ConsumerWidget {
  const DanbooruFileDetails({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagDetails =
        ref.watch(danbooruTagListProvider(ref.watchConfigAuth))[post.id];
    final uploader = ref.watch(danbooruCreatorProvider(post.uploaderId));
    final approver = ref.watch(danbooruCreatorProvider(post.approverId));

    return FileDetailsSection(
      post: post,
      rating: tagDetails != null ? tagDetails.rating : post.rating,
      uploader: uploader != null
          ? Row(
              children: [
                Flexible(
                  child: Material(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: InkWell(
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      onTap: () => goToUserDetailsPage(
                        context,
                        uid: uploader.id,
                      ),
                      child: Text(
                        uploader.name.replaceAll('_', ' '),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: uploader.getColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      customDetails: approver != null
          ? {
              'Approver': Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => goToUserDetailsPage(
                    context,
                    uid: approver.id,
                  ),
                  child: Text(
                    approver.name.replaceAll('_', ' '),
                    maxLines: 1,
                    style: TextStyle(
                      color: uploader.getColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            }
          : null,
    );
  }
}
