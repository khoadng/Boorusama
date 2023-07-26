// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:filesize/filesize.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class FileDetailsSection extends StatelessWidget {
  const FileDetailsSection({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Text(
            'post.detail.file_details'.tr(),
            style: context.textTheme.titleLarge!.copyWith(
              color: context.theme.hintColor,
              fontSize: 16,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FileDetailTile(
              title: 'post.detail.rating'.tr(),
              value: post.rating.toString().split('.').last.pascalCase,
            ),
            if (post.fileSize > 0)
              _FileDetailTile(
                title: 'post.detail.size'.tr(),
                value: filesize(post.fileSize, 1),
              ),
            _FileDetailTile(
              title: 'post.detail.resolution'.tr(),
              value: '${post.width.toInt()}x${post.height.toInt()}',
            ),
            _FileDetailTile(
              title: 'post.detail.file_format'.tr(),
              value: post.format,
            ),
          ],
        ),
      ],
    );
  }
}

class _FileDetailTile extends StatelessWidget {
  const _FileDetailTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Text(
        title,
        style: context.textTheme.titleLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: LayoutBuilder(
        builder: (context, constrainst) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          width: constrainst.maxWidth * 0.5,
          child: Text(
            value,
          ),
        ),
      ),
    );
  }
}
