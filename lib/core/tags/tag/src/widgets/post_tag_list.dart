// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../configs/ref.dart';
import '../../../../settings/data.dart';
import '../../../../theme.dart';
import '../../../../theme/utils.dart';
import '../tag.dart';
import '../tag_display.dart';
import '../tag_group_item.dart';
import '../tag_providers.dart';

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
        color: Theme.of(context).colorScheme.onSurface,
      );
    }

    final widgets = <Widget>[];
    for (final g in tags!) {
      widgets
        ..add(
          _TagBlockTitle(
            title: g.groupName,
            isFirstBlock: g.groupName == tags!.first.groupName,
          ),
        )
        ..add(
          _buildTags(
            context,
            g.tags,
          ),
        );
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
    final screenWith = MediaQuery.sizeOf(context).width;

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
          maxWidth: maxTagWidth ?? screenWith * 0.7,
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
              if (!ref.watchConfigAuth.hasStrictSFW && tag.postCount > 0)
                TextSpan(
                  text: '  ${NumberFormat.compact().format(tag.postCount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).brightness.isLight
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
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
