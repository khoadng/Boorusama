// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/display/media_query_utils.dart';
import '../../../../theme.dart';
import '../../../post/post.dart';
import '../../../rating/rating.dart';
import '../_internal/details_widget_frame.dart';
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
    return DetailsWidgetSeparator(
      child: Theme(
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
          child: _buildTile(),
        ),
      ),
    );
  }

  Widget _buildTile() {
    return LayoutBuilder(
      builder: (context, constraints) {
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

        final children = [
          FileDetailTile(
            title: 'ID',
            valueLabel: post.id.toString(),
            valueTrailing: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Transform.scale(
                  scale: 0.8,
                  child: const Icon(
                    FontAwesomeIcons.copy,
                    size: 20,
                  ),
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
            title: context.t.post.detail.rating,
            valueLabel: rating.name.pascalCase,
          ),
          if (post.fileSize > 0)
            FileDetailTile(
              title: context.t.post.detail.size,
              valueLabel: Filesize.parse(post.fileSize, round: 1),
            ),
          if (post.width > 0 && post.height > 0)
            FileDetailTile(
              title: context.t.post.detail.resolution,
              valueLabel: '${post.width.toInt()}x${post.height.toInt()}',
            ),
          FileDetailTile(
            title: context.t.post.detail.file_format,
            valueLabel: post.format,
          ),
          if (post.isVideo && post.duration > 0)
            FileDetailTile(
              title: 'Duration'.hc,
              valueLabel: '${post.duration.toInt()} seconds'.hc,
            ),
          if (uploader != null)
            FileDetailTile(
              title: 'Uploader'.hc,
              value: uploader,
            ),
          if (customDetails != null) ...[
            for (final detail in customDetails!.entries)
              FileDetailTile(
                title: detail.key,
                value: detail.value,
              ),
          ],
        ];

        return ExpansionTile(
          initiallyExpanded: initialExpanded,
          title: Text(
            context.t.post.detail.file_details,
          ),
          subtitle: Text(
            '$resolutionText$fileFormatText$fileSizeText • $ratingText',
            style: TextStyle(
              color: Theme.of(context).colorScheme.hintColor,
            ),
          ),
          children: constraints.maxWidth < 480
              ? children
              : [
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: children.sublist(
                            0,
                            (children.length / 2).ceil(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: children.sublist(
                            (children.length / 2).ceil(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
        );
      },
    );
  }
}
