// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/clipboard.dart';
import 'package:boorusama/foundation/filesize.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/string.dart';

class DefaultFileDetailsSection extends StatelessWidget {
  const DefaultFileDetailsSection({
    super.key,
    required this.post,
    this.uploaderName,
    this.customDetails,
  });

  final Post post;
  final String? uploaderName;
  final Map<String, Widget>? customDetails;

  @override
  Widget build(BuildContext context) {
    return FileDetailsSection(
      post: post,
      rating: post.rating,
      uploader: uploaderName != null
          ? Text(
              uploaderName!.replaceAll('_', ' '),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
              ),
            )
          : null,
      customDetails: customDetails,
    );
  }
}

class FileDetailsSection extends StatelessWidget {
  const FileDetailsSection({
    super.key,
    required this.post,
    required this.rating,
    this.uploader,
    this.customDetails,
  });

  final Post post;
  final Rating rating;
  final Widget? uploader;
  final Map<String, Widget>? customDetails;

  @override
  Widget build(BuildContext context) {
    final fileSizeText = post.fileSize > 0
        ? ' • ${Filesize.parse(post.fileSize, round: 1)}'
        : '';

    final resolutionText = post.width > 0 && post.height > 0
        ? '${post.width.toInt()}x${post.height.toInt()} • '
        : '';

    // if start with a dot, remove it
    final fileFormatText = post.format.startsWith('.')
        ? post.format.substring(1).toUpperCase()
        : post.format.toUpperCase();

    final ratingText = rating.name.getFirstCharacter().toUpperCase();

    return Theme(
      data: context.theme.copyWith(
        listTileTheme: context.theme.listTileTheme.copyWith(
          visualDensity: VisualDensity.compact,
        ),
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          'post.detail.file_details'.tr(),
        ),
        subtitle: Text(
          '$resolutionText$fileFormatText$fileSizeText • $ratingText',
          style: TextStyle(
            color: context.theme.hintColor,
          ),
        ),
        children: [
          _FileDetailTile(
              title: 'ID',
              valueLabel: post.id.toString(),
              valueTrailing: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  child: const Icon(
                    Symbols.content_copy,
                    size: 18,
                  ),
                  onTap: () {
                    AppClipboard.copyWithDefaultToast(
                      context,
                      post.id.toString(),
                    );
                  },
                ),
              )),
          _FileDetailTile(
            title: 'post.detail.rating'.tr(),
            valueLabel: rating.name.pascalCase,
          ),
          if (post.fileSize > 0)
            _FileDetailTile(
              title: 'post.detail.size'.tr(),
              valueLabel: Filesize.parse(post.fileSize, round: 1),
            ),
          if (post.width > 0 && post.height > 0)
            _FileDetailTile(
              title: 'post.detail.resolution'.tr(),
              valueLabel: '${post.width.toInt()}x${post.height.toInt()}',
            ),
          _FileDetailTile(
            title: 'post.detail.file_format'.tr(),
            valueLabel: post.format,
          ),
          if (post.isVideo && post.duration > 0)
            _FileDetailTile(
              title: 'Duration',
              valueLabel: '${post.duration.toInt()} seconds',
            ),
          if (uploader != null)
            _FileDetailTile(
              title: 'Uploader',
              value: uploader,
            ),
          if (customDetails != null) ...[
            for (final detail in customDetails!.entries)
              _FileDetailTile(
                title: detail.key,
                value: detail.value,
              )
          ]
        ],
      ),
    );
  }
}

class _FileDetailTile extends StatelessWidget {
  const _FileDetailTile({
    required this.title,
    this.valueLabel,
    this.value,
    this.valueTrailing,
  }) : assert(valueLabel != null || value != null);

  final String title;
  final String? valueLabel;
  final Widget? value;
  final Widget? valueTrailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: LayoutBuilder(
        builder: (context, constrainst) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          width: constrainst.maxWidth * 0.55,
          child: value ??
              (valueLabel != null
                  ? valueTrailing != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildValue(context),
                            const Spacer(),
                            valueTrailing!,
                          ],
                        )
                      : _buildValue(context)
                  : null),
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context) {
    return Text(
      valueLabel!,
      style: TextStyle(
        color: context.colorScheme.onSecondaryContainer,
        fontSize: 14,
      ),
    );
  }
}
