// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../posts/details_parts/widgets.dart';
import '../tag.dart';
import '../tag_display.dart';
import '../tag_group_item.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    required this.itemBuilder,
    required this.tags,
    super.key,
    this.maxTagWidth,
    this.padding,
  });

  final double? maxTagWidth;
  final Widget Function(BuildContext context, Tag tag) itemBuilder;
  final List<TagGroupItem>? tags;
  final EdgeInsetsGeometry? padding;

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

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widgets,
        ],
      ),
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

class PostTagListChip extends StatelessWidget {
  const PostTagListChip({
    required this.tag,
    required this.auth,
    super.key,
    this.maxTagWidth,
    this.onTap,
    this.color,
  });

  final Tag tag;
  final Color? color;
  final double? maxTagWidth;
  final void Function()? onTap;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context) {
    return TagChip(
      text: tag.displayName,
      auth: auth,
      category: tag.category.name,
      postCount: tag.postCount,
      onTap: onTap,
      maxWidth: maxTagWidth,
      colorOverride: color,
    );
  }
}

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
