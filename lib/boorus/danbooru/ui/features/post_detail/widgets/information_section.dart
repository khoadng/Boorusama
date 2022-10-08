// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'post_info.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({
    Key? key,
    required this.post,
    this.tappable = true,
    this.padding,
  }) : super(key: key);

  final Post post;
  final bool tappable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConditionalParentWidget(
          condition: tappable,
          conditionalBuilder: (child) => InkWell(
            onTap: () => showMaterialModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => PostInfo(
                  post: post,
                  scrollController: ModalScrollController.of(context)!),
            ),
            child: child,
          ),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                        dateTimeToStringTimeAgo(
                          post.createdAt,
                          locale: Localizations.localeOf(context).languageCode,
                        ),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                if (tappable)
                  const Flexible(child: Icon(Icons.keyboard_arrow_down))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
