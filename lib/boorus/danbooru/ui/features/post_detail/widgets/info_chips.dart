// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:filesize/filesize.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';

class InfoChips extends StatelessWidget {
  const InfoChips({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      children: [
        InfoChip(
          leftLabel: const Text('post.detail.rating').tr(),
          rightLabel: Text(post.rating.toString().split('.').last.pascalCase),
          leftColor: Theme.of(context).cardColor,
          rightColor: Theme.of(context).backgroundColor,
        ),
        InfoChip(
          leftLabel: const Text('post.detail.size').tr(),
          rightLabel: Text(filesize(post.fileSize, 1)),
          leftColor: Theme.of(context).cardColor,
          rightColor: Theme.of(context).backgroundColor,
        ),
        InfoChip(
          leftLabel: const Text('post.detail.resolution').tr(),
          rightLabel: Text('${post.width.toInt()}x${post.height.toInt()}'),
          leftColor: Theme.of(context).cardColor,
          rightColor: Theme.of(context).backgroundColor,
        ),
      ],
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({
    Key? key,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
  }) : super(key: key);

  final Color leftColor;
  final Color rightColor;
  final Widget leftLabel;
  final Widget rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: leftColor,
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).hintColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          label: leftLabel,
        ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: rightColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).hintColor),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: rightLabel,
        )
      ],
    );
  }
}
