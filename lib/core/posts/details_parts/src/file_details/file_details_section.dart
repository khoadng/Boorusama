// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/display/media_query_utils.dart';
import '../../../../theme.dart';
import '../../../post/post.dart';
import '../../../rating/rating.dart';
import 'file_detail_tile.dart';

class FileDetailsSection extends StatelessWidget {
  const FileDetailsSection({
    required this.post,
    required this.rating,
    super.key,
    this.uploader,
    this.customDetails,
    this.initialExpanded = false,
  });

  final Post post;
  final Rating rating;
  final Widget? uploader;
  final Map<String, Widget>? customDetails;
  final bool initialExpanded;

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
      data: Theme.of(context).copyWith(
        listTileTheme: Theme.of(context).listTileTheme.copyWith(
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
            ),
        dividerColor: Colors.transparent,
      ),
      child: RemoveLeftPaddingOnLargeScreen(
        child: ExpansionTile(
          initiallyExpanded: initialExpanded,
          title: Text(
            'post.detail.file_details'.tr(),
          ),
          subtitle: Text(
            '$resolutionText$fileFormatText$fileSizeText • $ratingText',
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
          children: [
            FileDetailTile(
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
              ),
            ),
            FileDetailTile(
              title: 'post.detail.rating'.tr(),
              valueLabel: rating.name.pascalCase,
            ),
            if (post.fileSize > 0)
              FileDetailTile(
                title: 'post.detail.size'.tr(),
                valueLabel: Filesize.parse(post.fileSize, round: 1),
              ),
            if (post.width > 0 && post.height > 0)
              FileDetailTile(
                title: 'post.detail.resolution'.tr(),
                valueLabel: '${post.width.toInt()}x${post.height.toInt()}',
              ),
            FileDetailTile(
              title: 'post.detail.file_format'.tr(),
              valueLabel: post.format,
            ),
            if (post.isVideo && post.duration > 0)
              FileDetailTile(
                title: 'Duration',
                valueLabel: '${post.duration.toInt()} seconds',
              ),
            if (uploader != null)
              FileDetailTile(
                title: 'Uploader',
                value: uploader,
              ),
            if (customDetails != null) ...[
              for (final detail in customDetails!.entries)
                FileDetailTile(
                  title: detail.key,
                  value: detail.value,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
