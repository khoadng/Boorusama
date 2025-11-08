// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/display/media_query_utils.dart';
import '../../../../themes/theme/types.dart';
import '../../../post/types.dart';
import '../../../rating/types.dart';
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
  final List<Widget>? customDetails;
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

        final format = normalizeUrl(post.format);

        // if start with a dot, remove it
        final fileFormatText = format.startsWith('.')
            ? format.substring(1).toUpperCase()
            : format.toUpperCase();

        final ratingText = rating.name.getFirstCharacter().toUpperCase();

        final children = [
          FileDetailTile(
            title: 'ID',
            valueLabel: post.id.toString(),
            valueTrailing: FileDetailsInWell(
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
            valueLabel: format,
          ),
          if (post.isVideo && post.duration > 0)
            FileDetailTile(
              title: context.t.post.detail.duration,
              valueLabel: context.t.time.counters.second(
                n: post.duration.toInt(),
              ),
            ),
          ?uploader,
          ...?customDetails,
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

class UploaderFileDetailTile extends StatelessWidget {
  const UploaderFileDetailTile({
    super.key,
    this.onViewDetails,
    this.onSearch,
    this.textStyle,
    required this.uploaderName,
  });

  final VoidCallback? onViewDetails;
  final VoidCallback? onSearch;
  final String uploaderName;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return FileDetailTile(
      title: context.t.post.detail.uploader,
      value: FileDetailsInWell(
        onTap: onViewDetails,
        child: Text(
          uploaderName.replaceAll('_', ' '),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
      valueTrailing: onSearch == null
          ? null
          : FileDetailsActionIconButton(onTap: onSearch),
    );
  }
}

class FileDetailsActionIconButton extends StatelessWidget {
  const FileDetailsActionIconButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FileDetailsInWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Transform.scale(
          scale: 0.8,
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class FileDetailsInWell extends StatelessWidget {
  const FileDetailsInWell({
    super.key,
    this.borderRadius,
    this.onTap,
    required this.child,
  });

  final BorderRadiusGeometry? borderRadius;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(8)),
    );

    return Material(
      color: Colors.transparent,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
