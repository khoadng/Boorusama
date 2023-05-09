// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/ui/tags.dart';
import 'package:boorusama/core/ui/widgets/context_menu.dart';

class SimplePostTagList extends ConsumerWidget {
  const SimplePostTagList({
    super.key,
    required this.tags,
  });

  final List<PostDetailTag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);

    return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
      builder: (context, state) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final booru = state.booru ?? safebooru();
            final tags_ = [
              ...tags.where(
                (e) => e.category == TagCategory.artist.stringify(),
              ),
              ...tags.where(
                (e) => e.category == TagCategory.copyright.stringify(),
              ),
              ...tags.where(
                (e) => e.category == TagCategory.charater.stringify(),
              ),
              ...tags.where(
                (e) => e.category == TagCategory.general.stringify(),
              ),
              ...tags.where((e) => e.category == TagCategory.meta.stringify()),
            ].map((e) => _Tag(
                  rawName: e.name,
                  displayName: e.name.replaceAll('_', ' '),
                  category: TagCategory.meta,
                  color: getTagColor(
                    stringToTagCategory(e.category),
                    themeState.theme,
                  ),
                ));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags_
                      .map((tag) => ContextMenu<String>(
                            items: [
                              // PopupMenuItem(
                              //     value: 'blacklist',
                              //     child: const Text('post.detail.add_to_blacklist').tr()),
                              PopupMenuItem(
                                value: 'wiki',
                                child: const Text('post.detail.open_wiki').tr(),
                              ),
                              if (authState is Authenticated)
                                const PopupMenuItem(
                                  value: 'copy_and_move_to_saved_search',
                                  child: Text(
                                    'Copy to clipboard and move to saved search',
                                  ),
                                ),
                            ],
                            onSelected: (value) {
                              // ignore: no-empty-block
                              if (value == 'blacklist') {
                                // onAddToBlacklisted(tag);
                              } else if (value == 'wiki') {
                                launchWikiPage(
                                  booru.url,
                                  tag.rawName,
                                );
                              } else if (value ==
                                  'copy_and_move_to_saved_search') {
                                Clipboard.setData(
                                  ClipboardData(text: tag.rawName),
                                ).then(
                                  (value) => goToSavedSearchEditPage(context),
                                );
                              }
                            },
                            child: _Badge(
                              label: tag.displayName,
                              backgroundColor: tag.color,
                              onTap: () =>
                                  goToSearchPage(context, tag: tag.rawName),
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Tag {
  _Tag({
    required this.rawName,
    required this.displayName,
    required this.category,
    required this.color,
  });

  final String rawName;
  final String displayName;
  final TagCategory category;
  final Color color;
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: label.length < 6 ? 10 : 4,
            vertical: 4,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
