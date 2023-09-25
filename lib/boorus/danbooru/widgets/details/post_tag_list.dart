// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostTagList extends ConsumerWidget {
  const PostTagList({
    super.key,
    this.maxTagWidth,
  });

  final double? maxTagWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);
    final booru = ref.watch(currentBooruConfigProvider);
    final tags = ref.watch(tagsProvider(booru));

    if (tags == null) {
      return SpinKitPulse(
        size: 42,
        color: context.colorScheme.onBackground,
      );
    }

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
          authState,
          g.tags,
          onAddToBlacklisted: (tag) => ref
              .read(danbooruBlacklistedTagsProvider.notifier)
              .addWithToast(tag: tag.rawName),
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
    BooruConfig booru,
    AuthenticationState authenticationState,
    List<Tag> tags, {
    required void Function(Tag tag) onAddToBlacklisted,
  }) {
    return Tags(
      alignment: WrapAlignment.start,
      runSpacing: isMobilePlatform() ? 0 : 4,
      itemCount: tags.length,
      itemBuilder: (index) {
        final tag = tags[index];

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
            if (authenticationState.isAuthenticated)
              PopupMenuItem(
                value: 'blacklist',
                child: const Text('post.detail.add_to_blacklist').tr(),
              ),
            if (authenticationState.isAuthenticated)
              PopupMenuItem(
                value: 'copy_and_move_to_saved_search',
                child: const Text(
                  'post.detail.copy_and_open_saved_search',
                ).tr(),
              ),
          ],
          onSelected: (value) {
            if (value == 'blacklist') {
              onAddToBlacklisted(tag);
            } else if (value == 'wiki') {
              launchWikiPage(booru.url, tag.rawName);
            } else if (value == 'copy_and_move_to_saved_search') {
              Clipboard.setData(
                ClipboardData(text: tag.rawName),
              ).then((value) => goToSavedSearchEditPage(context));
            } else if (value == 'add_to_favorites') {
              ref.read(favoriteTagsProvider.notifier).add(tag.rawName);
            }
          },
          child: GestureDetector(
            onTap: () => goToSearchPage(context, tag: tag.rawName),
            child: _Chip(tag: tag, maxTagWidth: maxTagWidth),
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
  });

  final Tag tag;
  final double? maxTagWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.themeMode;
    final colors = generateChipColors(getTagColor(tag.category, theme), theme);
    final numberColors = generateChipColors(Colors.grey[600]!, theme);

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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxTagWidth ?? MediaQuery.of(context).size.width * 0.7,
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
        Chip(
          visualDensity: const ShrinkVisualDensity(),
          backgroundColor: numberColors.backgroundColor,
          side: BorderSide(
            color: numberColors.borderColor,
            width: 1,
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
