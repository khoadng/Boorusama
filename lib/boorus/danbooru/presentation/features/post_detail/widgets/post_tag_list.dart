// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/blacklisted_tags/blacklisted_tag_provider_widget.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/modal_options.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/api/api.dart';
import 'package:boorusama/core/application/utils.dart';

class PostTagList extends StatelessWidget {
  const PostTagList({
    Key? key,
  }) : super(key: key);

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
          } else if (state.status == LoadStatus.failure) {
            return const SizedBox.shrink();
          } else {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
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
          runSpacing: 0,
          itemCount: tags.length,
          itemBuilder: (index) {
            final tag = tags[index];
            final tagKey = GlobalKey();

            return GestureDetector(
              onTap: () => AppRouter.router.navigateTo(
                context,
                '/posts/search',
                routeSettings: RouteSettings(arguments: [tag.rawName]),
              ),
              onLongPress: () {
                showActionListModalBottomSheet(
                  context: context,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Open wiki'),
                      onTap: () {
                        Navigator.of(context).pop();
                        launchWikiPage(state.booru.url, tag.rawName);
                      },
                    ),
                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        if (state is Authenticated) {
                          return ListTile(
                            leading: const FaIcon(
                              FontAwesomeIcons.plus,
                            ),
                            title: const Text('Add to blacklist'),
                            onTap: () {
                              Navigator.of(context).pop();
                              onAddToBlacklisted(tag);
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                );
              },
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    key: tagKey,
                    children: [
                      Chip(
                          visualDensity:
                              const VisualDensity(horizontal: -4, vertical: -4),
                          backgroundColor:
                              getTagColor(tag.category, state.theme),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8))),
                          label: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.70),
                            child: Text(
                              tag.displayName,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: state.theme == ThemeMode.light
                                      ? Colors.white
                                      : Colors.white),
                            ),
                          )),
                      Chip(
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        backgroundColor: Colors.grey[800],
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8))),
                        label: Text(
                          tag.postCount.toString(),
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      )
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

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
