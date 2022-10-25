// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/tags/tags.dart';
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/ui/widgets/context_menu.dart';

class SimplePostTagList extends StatelessWidget {
  const SimplePostTagList({
    super.key,
    required this.tags,
  });

  final List<PostDetailTag> tags;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
      builder: (context, state) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final tags_ = [
              ...tags
                  .where((e) => e.category == TagAutocompleteCategory.artist()),
              ...tags.where(
                (e) => e.category == TagAutocompleteCategory.copyright(),
              ),
              ...tags.where(
                (e) => e.category == TagAutocompleteCategory.character(),
              ),
              ...tags.where(
                (e) => e.category == TagAutocompleteCategory.general(),
              ),
              ...tags
                  .where((e) => e.category == TagAutocompleteCategory.meta()),
            ].map((e) => _Tag(
                  rawName: e.name,
                  displayName: e.name.replaceAll('_', ' '),
                  category: TagCategory.meta,
                  color: getTagColor(
                    TagCategory.values[e.category.getIndex()],
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
                            ],
                            onSelected: (value) {
                              // ignore: no-empty-block
                              if (value == 'blacklist') {
                                // onAddToBlacklisted(tag);
                              } else if (value == 'wiki') {
                                launchWikiPage(state.booru.url, tag.rawName);
                              }
                            },
                            child: _Badge(
                              label: tag.displayName,
                              backgroundColor: tag.color,
                              onTap: () => AppRouter.router.navigateTo(
                                context,
                                '/posts/search',
                                routeSettings:
                                    RouteSettings(arguments: [tag.rawName]),
                              ),
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
