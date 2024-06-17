// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';

class InfoChips extends StatelessWidget {
  const InfoChips({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      children: [
        _InfoChip(
          leftLabel: const Text('post.detail.rating').tr(),
          rightLabel: Text(post.rating.toString().split('.').last.pascalCase),
          leftColor: context.colorScheme.surfaceContainerHighest,
          rightColor: context.colorScheme.surface,
        ),
        _InfoChip(
          leftLabel: const Text('post.detail.size').tr(),
          rightLabel: Text(filesize(post.fileSize, 1)),
          leftColor: context.colorScheme.surfaceContainerHighest,
          rightColor: context.colorScheme.surface,
        ),
        _InfoChip(
          leftLabel: const Text('post.detail.resolution').tr(),
          rightLabel: Text('${post.width.toInt()}x${post.height.toInt()}'),
          leftColor: context.colorScheme.surfaceContainerHighest,
          rightColor: context.colorScheme.surface,
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
  });

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
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: leftColor,
          labelPadding: const EdgeInsets.symmetric(horizontal: 1),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: context.theme.hintColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          label: leftLabel,
        ),
        Chip(
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: rightColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: context.theme.hintColor),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          label: rightLabel,
        ),
      ],
    );
  }
}
