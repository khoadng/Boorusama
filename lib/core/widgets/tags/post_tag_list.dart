// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    super.key,
    this.maxTagWidth,
    this.onTap,
    required this.tags,
  });

  final double? maxTagWidth;
  final void Function(Tag tag)? onTap;
  final List<TagGroupItem>? tags;

  @override
  Widget build(BuildContext context) {
    if (tags == null) {
      return SpinKitPulse(
        size: 42,
        color: context.colorScheme.onBackground,
      );
    }

    final widgets = <Widget>[];
    for (final g in tags!) {
      widgets
        ..add(_TagBlockTitle(
          title: g.groupName,
          isFirstBlock: g.groupName == tags!.first.groupName,
        ))
        ..add(_buildTags(
          context,
          g.tags,
          onTap,
        ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widgets,
      ],
    );
  }

  Widget _buildTags(
    BuildContext context,
    List<Tag> tags,
    void Function(Tag tag)? onTap,
  ) {
    return Tags(
      alignment: WrapAlignment.start,
      runSpacing: isMobilePlatform() ? 0 : 4,
      itemCount: tags.length,
      itemBuilder: (index) {
        final tag = tags[index];

        return GestureDetector(
          onTap: () => onTap?.call(tag),
          child: _Chip(tag: tag, maxTagWidth: maxTagWidth),
        );
      },
    );
  }
}

class _Chip extends ConsumerWidget {
  const _Chip({
    required this.tag,
    required this.maxTagWidth,
  });

  final Tag tag;
  final double? maxTagWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.themeMode;
    final colors =
        generateChipColors(ref.getTagColor(context, tag.category.name), theme);
    final numberColors = generateChipColors(Colors.grey[800]!, theme);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: colors.backgroundColor,
          side: BorderSide(
            width: 1,
            color: colors.borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: tag.hasPost
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                : const BorderRadius.all(Radius.circular(8)),
          ),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxTagWidth ?? context.screenWidth * 0.7,
            ),
            child: Text(
              _getTagStringDisplayName(tag),
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.foregroundColor,
              ),
            ),
          ),
        ),
        if (tag.hasPost)
          Chip(
            visualDensity: const ShrinkVisualDensity(),
            backgroundColor: numberColors.backgroundColor,
            side: BorderSide(
              width: 1,
              color: numberColors.borderColor,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            label: Text(
              NumberFormat.compact().format(tag.postCount),
              style: TextStyle(
                color: numberColors.foregroundColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

String _getTagStringDisplayName(Tag tag) => tag.displayName.length > 30
    ? '${tag.displayName.substring(0, 30)}...'
    : tag.displayName;

class _TagBlockTitle extends StatelessWidget {
  const _TagBlockTitle({
    required this.title,
    this.isFirstBlock = false,
  });

  final bool isFirstBlock;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 5,
      ),
      _TagHeader(
        title: title,
      ),
    ]);
  }
}

class _TagHeader extends StatelessWidget {
  const _TagHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        title,
        style:
            context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
