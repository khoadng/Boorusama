// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    super.key,
    this.maxTagWidth,
    required this.itemBuilder,
    required this.tags,
  });

  final double? maxTagWidth;
  final Widget Function(BuildContext context, Tag tag) itemBuilder;
  final List<TagGroupItem>? tags;

  @override
  Widget build(BuildContext context) {
    if (tags == null) {
      return SpinKitPulse(
        size: 42,
        color: context.colorScheme.onSurface,
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 6,
          children: tags
              .map(
                (tag) => itemBuilder(context, tag),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class PostTagListChip extends ConsumerWidget {
  const PostTagListChip({
    super.key,
    required this.tag,
    this.maxTagWidth,
    this.onTap,
    this.color,
  });

  final Tag tag;
  final Color? color;
  final double? maxTagWidth;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      color ?? ref.watch(tagColorProvider(tag.category.name)),
      ref.watch(settingsProvider),
    );

    return RawCompactChip(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      foregroundColor: colors?.foregroundColor,
      backgroundColor: colors?.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: colors != null
            ? BorderSide(
                color: colors.borderColor,
              )
            : BorderSide.none,
      ),
      label: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxTagWidth ?? context.screenWidth * 0.7,
        ),
        child: RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: _getTagStringDisplayName(tag),
            style: TextStyle(
              color: colors?.foregroundColor,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (!ref.watchConfig.hasStrictSFW && tag.postCount > 0)
                TextSpan(
                  text: '  ${NumberFormat.compact().format(tag.postCount)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: context.isLight
                        ? Colors.white.withOpacity(0.85)
                        : Colors.grey.withOpacity(0.85),
                  ),
                ),
            ],
          ),
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 8,
        ),
        _TagHeader(
          title: title,
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    );
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
            context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
