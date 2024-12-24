// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/downloads/routes.dart';
import '../../../../../../core/images/booru_image.dart';
import '../../../../../../core/posts/listing/providers.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/posts/post/widgets.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../listing/widgets.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';
import '../../favgroups/favgroup.dart';
import '../../favgroups/providers.dart';
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
            itemBuilder:
                (context, index, multiSelectController, autoScrollController) {
              return DefaultDanbooruImageGridItem(
                index: index,
                multiSelectController: multiSelectController,
                autoScrollController: autoScrollController,
                controller: controller,
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
          context,
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
        final notifier =
            ref.read(danbooruFavoriteGroupsProvider(config).notifier);

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
                  onFailure: (message, translatable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message.tr()),
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
        title: const Text('Edit'),
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
          header: const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Long press and drag to reorder',
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
                    InkWell(
                      onTap: () => goToImagePreviewPage(context, post),
                      child: LimitedBox(
                        maxWidth: 80,
                        child: BooruImage(
                          fit: BoxFit.cover,
                          imageUrl: post.thumbnailImageUrl,
                        ),
                      ),
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

void goToImagePreviewPage(BuildContext context, DanbooruPost post) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) =>
        QuickPreviewImageDialog(
      child: BooruImage(
        fit: BoxFit.contain,
        imageUrl: post.sampleImageUrl,
      ),
    ),
  );
}
