// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_category.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

typedef E621TagGroup = ({
  String groupName,
  E621TagCategory category,
  List<String> tags,
});

class E621PostTagList extends ConsumerWidget {
  const E621PostTagList({
    super.key,
    this.maxTagWidth,
    required this.post,
  });

  final double? maxTagWidth;
  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watchConfig;
    final tags = <E621TagGroup>[
      if (post.artistTags.isNotEmpty)
        (
          groupName: 'Artist',
          category: E621TagCategory.artist,
          tags: post.artistTags,
        ),
      if (post.characterTags.isNotEmpty)
        (
          groupName: 'Character',
          category: E621TagCategory.charater,
          tags: post.characterTags,
        ),
      if (post.copyrightTags.isNotEmpty)
        (
          groupName: 'Copyright',
          category: E621TagCategory.copyright,
          tags: post.copyrightTags,
        ),
      if (post.speciesTags.isNotEmpty)
        (
          groupName: 'Species',
          category: E621TagCategory.species,
          tags: post.speciesTags,
        ),
      if (post.generalTags.isNotEmpty)
        (
          groupName: 'General',
          category: E621TagCategory.general,
          tags: post.generalTags,
        ),
      if (post.metaTags.isNotEmpty)
        (
          groupName: 'Meta',
          category: E621TagCategory.meta,
          tags: post.metaTags,
        ),
    ];

    final widgets = <Widget>[];
    for (final g in tags) {
      widgets
        ..add(_TagBlockTitle(
          title: g.groupName,
          isFirstBlock: g.groupName == tags.first.groupName,
        ))
        ..add(_buildTags(
          context,
          ref,
          booru,
          g,
          // onAddToBlacklisted: (tag) =>
          //     ref.read(danbooruBlacklistedTagsProvider.notifier).add(
          //           tag: tag.rawName,
          //           onFailure: (message) => showSimpleSnackBar(
          //             context: context,
          //             content: Text(message),
          //           ),
          //           onSuccess: (_) => showSimpleSnackBar(
          //             context: context,
          //             duration: const Duration(seconds: 2),
          //             content: const Text('Blacklisted tags updated'),
          //           ),
          //         ),
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
    WidgetRef ref,
    BooruConfig config,
    E621TagGroup group,
    // {
    // required void Function(Tag tag) onAddToBlacklisted,
    // }
  ) {
    return Tags(
      alignment: WrapAlignment.start,
      runSpacing: isMobilePlatform() ? 0 : 4,
      itemCount: group.tags.length,
      itemBuilder: (index) {
        final tag = group.tags[index];

        return ContextMenu<String>(
          items: [
            PopupMenuItem(
              value: 'wiki',
              child: const Text('post.detail.open_wiki').tr(),
            ),
            PopupMenuItem(
              value: 'add_to_favorites',
              child: const Text('post.detail.add_to_favorites').tr(),
            ),
            // if (authenticationState.isAuthenticated)
            //   PopupMenuItem(
            //     value: 'blacklist',
            //     child: const Text('post.detail.add_to_blacklist').tr(),
            //   ),
          ],
          onSelected: (value) {
            // if (value == 'blacklist') {
            //   onAddToBlacklisted(tag);
            // } else
            if (value == 'wiki') {
              launchWikiPage(config.url, tag);
            } else if (value == 'add_to_favorites') {
              ref.read(favoriteTagsProvider.notifier).add(tag);
            }
          },
          child: GestureDetector(
            onTap: () => goToSearchPage(context, tag: tag),
            child: _Chip(
              tag: tag,
              tagColor: group.category.toColor(),
              maxTagWidth: maxTagWidth,
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends ConsumerWidget {
  const _Chip({
    required this.tag,
    required this.maxTagWidth,
    required this.tagColor,
  });

  final String tag;
  final Color tagColor;
  final double? maxTagWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = generateChipColors(tagColor, context.themeMode);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: colors.backgroundColor,
          side: BorderSide(
            color: colors.borderColor,
            width: 1,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxTagWidth ?? MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              _getTagStringDisplayName(tag.replaceUnderscoreWithSpace()),
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.foregroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _getTagStringDisplayName(String tag) =>
    tag.length > 30 ? '${tag.substring(0, 30)}...' : tag;

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
