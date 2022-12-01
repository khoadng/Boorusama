// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tag_provider_widget.dart';
import 'package:boorusama/boorus/danbooru/ui/features/tags/tags.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/tags/favorite_tag_bloc.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/application/utils.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/context_menu.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    super.key,
    this.maxTagWidth,
  });

  final double? maxTagWidth;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        return BlacklistedTagProviderWidget(
          builder: (context, action) => BlocBuilder<TagBloc, TagState>(
            builder: (context, state) {
              if (state.status == LoadStatus.success) {
                final widgets = <Widget>[];
                for (final g in state.tags!) {
                  widgets
                    ..add(_TagBlockTitle(
                      title: g.groupName,
                      isFirstBlock: g.groupName == state.tags!.first.groupName,
                    ))
                    ..add(_buildTags(
                      context,
                      authState,
                      g.tags,
                      onAddToBlacklisted: (tag) => action(tag),
                    ));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widgets,
                  ],
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }
            },
          ),
          operation: BlacklistedOperation.add,
        );
      },
    );
  }

  Widget _buildTags(
    BuildContext context,
    AuthenticationState authenticationState,
    List<Tag> tags, {
    required void Function(Tag tag) onAddToBlacklisted,
  }) {
    return BlocBuilder<ApiEndpointCubit, ApiEndpointState>(
      builder: (context, state) {
        return Tags(
          alignment: WrapAlignment.start,
          runSpacing: isMobilePlatform() ? 0 : 4,
          itemCount: tags.length,
          itemBuilder: (index) {
            final tag = tags[index];

            return ContextMenu<String>(
              items: [
                // PopupMenuItem(
                //     value: 'blacklist',
                //     child: const Text('post.detail.add_to_blacklist').tr()),
                PopupMenuItem(
                  value: 'wiki',
                  child: const Text('post.detail.open_wiki').tr(),
                ),
                PopupMenuItem(
                  value: 'add_to_favorites',
                  child: const Text('post.detail.add_to_favorites').tr(),
                ),
                if (authenticationState is Authenticated)
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
                  launchWikiPage(state.booru.url, tag.rawName);
                } else if (value == 'copy_and_move_to_saved_search') {
                  Clipboard.setData(
                    ClipboardData(text: tag.rawName),
                  ).then((value) => AppRouter.router.navigateTo(
                        context,
                        '/saved_search/edit',
                      ));
                } else if (value == 'add_to_favorites') {
                  context
                      .read<FavoriteTagBloc>()
                      .add(FavoriteTagAdded(tag: tag.rawName));
                }
              },
              child: GestureDetector(
                onTap: () => AppRouter.router.navigateTo(
                  context,
                  '/posts/search',
                  routeSettings: RouteSettings(arguments: [tag.rawName]),
                ),
                child: _Chip(tag: tag, maxTagWidth: maxTagWidth),
              ),
            );
          },
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.tag,
    required this.maxTagWidth,
  });

  final Tag tag;
  final double? maxTagWidth;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              backgroundColor: getTagColor(tag.category, state.theme),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              label: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      maxTagWidth ?? MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  _getTagStringDisplayName(tag),
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Chip(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              backgroundColor: Colors.grey[800],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              label: Text(
                NumberFormat.compact().format(tag.postCount),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        );
      },
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
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
