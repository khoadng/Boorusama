// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/utils.dart';
import 'post_info_modal.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showMaterialModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => PostInfoModal(
            post: post, scrollController: ModalScrollController.of(context)!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.characterTags.isEmpty
                        ? 'Original'
                        : post.name.characterOnly
                            .removeUnderscoreWithSpace()
                            .titleCase,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 5),
                  Text(
                      post.copyrightTags.isEmpty
                          ? 'Original'
                          : post.name.copyRightOnly
                              .removeUnderscoreWithSpace()
                              .titleCase,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(height: 5),
                  Text(
                    dateTimeToStringTimeAgo(post.createdAt),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
            const Flexible(child: Icon(Icons.keyboard_arrow_down)),
          ],
        ),
      ),
    );
  }
}
