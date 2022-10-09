// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/blacklisted_tags/blacklisted_tag_provider_widget.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/utils.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/context_menu.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({Key? key, this.maxTagWidth}) : super(key: key);

  final double? maxTagWidth;

  @override
  Widget build(BuildContext context) {
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
                  g.tags,
                  onAddToBlacklisted: (tag) => action(tag),
                ));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widgets,
              ],
            );
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
        },
      ),
      operation: BlacklistedOperation.add,
    );
  }

  Widget _buildTags(
    BuildContext context,
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
                    child: const Text('post.detail.open_wiki').tr()),
              ],
              onSelected: (value) {
                if (value == 'blacklist') {
                  onAddToBlacklisted(tag);
                } else if (value == 'wiki') {
                  launchWikiPage(state.booru.url, tag.rawName);
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
    Key? key,
    required this.tag,
    required this.maxTagWidth,
  }) : super(key: key);

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
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
                backgroundColor: getTagColor(tag.category, state.theme),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8))),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: maxTagWidth ??
                          MediaQuery.of(context).size.width * 0.70),
                  child: Text(
                    _getTagStringDisplayName(tag),
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: state.theme == ThemeMode.light
                            ? Colors.white
                            : Colors.white),
                  ),
                )),
            Chip(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              backgroundColor: Colors.grey[800],
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
              label: Text(
                tag.postCount.toString(),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            )
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
  const _TagBlockTitle(
      {required this.title, Key? key, this.isFirstBlock = false})
      : super(key: key);

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
    Key? key,
    required this.title,
  }) : super(key: key);

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
