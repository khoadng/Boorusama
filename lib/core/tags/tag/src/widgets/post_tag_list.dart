// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../posts/details_parts/widgets.dart';
import '../../../../theme/providers.dart';
import '../tag.dart';
import '../tag_display.dart';
import '../tag_group_item.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    required this.itemBuilder,
    required this.tags,
    super.key,
    this.maxTagWidth,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = color != null
        ? ref.watch(booruChipColorsProvider).fromColor(color)
        : ref.watch(
            chipColorsFromTagStringProvider(
              (auth, tag.category.name),
            ),
          );

    final subtitle = (!auth.hasStrictSFW && tag.postCount > 0)
        ? NumberFormat.compact().format(tag.postCount)
        : null;

    return RawTagChip(
      text: tag.displayName,
      subtitle: subtitle,
      onTap: onTap,
      maxWidth: maxTagWidth,
      backgroundColor: colors?.backgroundColor,
      foregroundColor: colors?.foregroundColor,
      borderColor: colors?.borderColor,
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
