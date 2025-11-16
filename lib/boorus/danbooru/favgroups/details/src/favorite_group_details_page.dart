// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/bulk_downloads/routes.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../../../core/posts/listing/routes.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/providers.dart';
import '../../../posts/post/types.dart';
import '../../favgroups/providers.dart';
import '../../favgroups/types.dart';
import 'danbooru_favorite_group_post_mixin.dart';

class FavoriteGroupDetailsPage extends ConsumerStatefulWidget {
  const FavoriteGroupDetailsPage({
    required this.group,
    super.key,
  });

  final DanbooruFavoriteGroup group;

  @override
  ConsumerState<FavoriteGroupDetailsPage> createState() =>
      _FavoriteGroupDetailsPageState();
}

class _FavoriteGroupDetailsPageState
    extends ConsumerState<FavoriteGroupDetailsPage>
    with DanbooruFavoriteGroupPostMixin {
  late var postIds = Queue<int>.from(widget.group.postIds);

  @override
  PostRepository<DanbooruPost> get postRepository =>
      ref.read(danbooruPostRepoProvider(ref.readConfigSearch));

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigSearch;

    return CustomContextMenuOverlay(
      child: Scaffold(
        body: PostScope(
          fetcher: (page) => TaskEither.Do(($) {
            return getPostsFromIdQueue(
              postIds,
              page - 1,
              limit: 200,
            );
          }),
          builder: (context, controller) => PostGrid(
            controller: controller,
            sliverHeaders: [
              SliverAppBar(
                centerTitle: false,
                title: Text(widget.group.name.replaceAll('_', ' ')),
                actions: [
                  _buildSearchButton(),
                  _buildDownloadButton(),
                  _buildEditButton(controller, config),
                ],
                floating: true,
                snap: true,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ],
            itemBuilder: (context, index, autoScrollController, useHero) {
              return DanbooruPostListingContextMenu(
                index: index,
                controller: controller,
                child: DefaultDanbooruImageGridItem(
                  index: index,
                  autoScrollController: autoScrollController,
                  controller: controller,
                  useHero: useHero,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return IconButton(
      onPressed: () {
        goToBulkDownloadPage(
          context,
          [widget.group.getQueryString()],
          ref: ref,
        );
      },
      icon: const Icon(Symbols.download),
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      onPressed: () {
        goToSearchPage(
          ref,
          tag: widget.group.getQueryString(),
        );
      },
      icon: const Icon(Symbols.search),
    );
  }

  Widget _buildEditButton(
    PostGridController<DanbooruPost> controller,
    BooruConfigSearch config,
  ) {
    return IconButton(
      onPressed: () {
        final notifier = ref.read(
          danbooruFavoriteGroupsProvider(config).notifier,
        );

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => FavoriteGroupEditPage(
              posts: controller.allItems.toList(),
              onSave: (reorderedPosts) async {
                final updatedIds = await notifier.editIds(
                  group: widget.group,
                  allIds: postIds.toSet(),
                  newIds: reorderedPosts.map((e) => e.id).toSet(),
                  oldIds: controller.allItems.map((e) => e.id).toSet(),
                  onFailure: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                      ),
                    );
                  },
                );

                if (updatedIds != null) {
                  setState(() {
                    postIds = Queue<int>.from(updatedIds);
                    controller.refresh();
                  });
                }
              },
            ),
          ),
        );
      },
      icon: const Icon(
        Symbols.edit,
        fill: 1,
      ),
    );
  }
}

class FavoriteGroupEditPage extends StatefulWidget {
  const FavoriteGroupEditPage({
    required this.posts,
    required this.onSave,
    super.key,
  });

  final List<DanbooruPost> posts;
  final void Function(List<DanbooruPost> posts) onSave;

  @override
  State<FavoriteGroupEditPage> createState() => _FavoriteGroupEditPageState();
}

class _FavoriteGroupEditPageState extends State<FavoriteGroupEditPage> {
  late final List<DanbooruPost> posts = widget.posts;

  void _onReorder(int oldIndex, int newIndex) {
    var newIdx = newIndex;

    if (newIdx > oldIndex) {
      newIdx -= 1;
    }

    final post = posts.removeAt(oldIndex);
    posts.insert(newIdx, post);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.generic.action.edit),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(posts);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ReorderableListView.builder(
          header: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              context.t.favorite_groups.drag_hint,
            ),
          ),
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            return Container(
              key: ValueKey(post.id),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Consumer(
                      builder: (_, ref, _) {
                        final config = ref.watchConfigAuth;

                        return InkWell(
                          onTap: () => goToImagePreviewPage(
                            context,
                            post,
                            config,
                          ),
                          child: LimitedBox(
                            maxWidth: 80,
                            child: BooruImage(
                              config: config,
                              fit: BoxFit.cover,
                              imageUrl: post.thumbnailImageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(post.id.toString()),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up),
                      onPressed: () {
                        if (index > 0) {
                          setState(() {
                            final post = posts.removeAt(index);
                            posts.insert(index - 1, post);
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () {
                        if (index < posts.length - 1) {
                          setState(() {
                            final post = posts.removeAt(index);
                            posts.insert(index + 1, post);
                          });
                        }
                      },
                    ),
                    //delete button
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        setState(() {
                          posts.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: widget.posts.length,
          onReorder: _onReorder,
        ),
      ),
    );
  }
}
