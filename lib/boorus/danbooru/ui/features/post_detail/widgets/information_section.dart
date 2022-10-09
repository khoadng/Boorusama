// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/core.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({
    Key? key,
    required this.post,
    this.padding,
  }) : super(key: key);

  final Post post;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
            ],
          ),
        ),
      ],
    );
  }
}
