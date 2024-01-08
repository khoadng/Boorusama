// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
    return Tags(
      alignment: WrapAlignment.start,
      runSpacing: 4,
      itemCount: tags.length,
      itemBuilder: (index) {
        final tag = tags[index];
        return itemBuilder(context, tag);
      },
    );
  }
}

class PostTagListChip extends ConsumerWidget {
  const PostTagListChip({
    super.key,
    required this.tag,
    this.maxTagWidth,
    this.onTap,
  });

  final Tag tag;
  final double? maxTagWidth;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      ref.getTagColor(context, tag.category.name),
      ref.watch(settingsProvider),
    );

    return SizedBox(
      height: 28,
      child: RawChip(
        onPressed: onTap,
        padding: isMobilePlatform() ? const EdgeInsets.all(4) : EdgeInsets.zero,
        visualDensity: const ShrinkVisualDensity(),
        backgroundColor: colors?.backgroundColor,
        side: colors != null
            ? BorderSide(
                color: colors.borderColor,
                width: 1,
              )
            : null,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
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
                if (!ref.watchConfig.hasStrictSFW)
                  TextSpan(
                    text: '  ${NumberFormat.compact().format(tag.postCount)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: context.themeMode.isLight
                          ? Colors.white.withOpacity(0.85)
                          : Colors.grey.withOpacity(0.85),
                    ),
                  ),
              ],
            ),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 8,
      ),
      _TagHeader(
        title: title,
      ),
      const SizedBox(
        height: 4,
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
