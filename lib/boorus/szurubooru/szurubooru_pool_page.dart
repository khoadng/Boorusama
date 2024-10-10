// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/clients/szurubooru/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/pools/pools.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/functional.dart';
import 'add_to_pool_page.dart';
import 'providers.dart';

class SzurubooruPoolPage extends StatelessWidget {
  const SzurubooruPoolPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        bottom: false,
        child: _PostList(),
      ),
    );
  }
}

const double _kLabelOffset = 0.2;

class _PostList extends ConsumerWidget {
  const _PostList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              titleSpacing: 0,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              title: const Text('pool.pool_gallery').tr(),
            ),
            PoolPagedSliverGrid(
              constraints: constraints,
            ),
          ],
        );
      },
    );
  }
}

class PoolPagedSliverGrid extends ConsumerStatefulWidget {
  const PoolPagedSliverGrid({
    super.key,
    required this.constraints,
    this.name,
    this.description,
  });

  final BoxConstraints constraints;
  final String? name;
  final String? description;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PoolPagedSliverGridState();
}

class _PoolPagedSliverGridState extends ConsumerState<PoolPagedSliverGrid> {
  late var name = widget.name;
  late var description = widget.description;

  final controller = PagingController<int, PoolDto>(
    firstPageKey: 0,
  );

  @override
  void initState() {
    controller.addPageRequestListener((pageKey) {
      _fetchPage(
        pageKey,
        name: name,
        description: description,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> _fetchPage(
    int pageKey, {
    String? name,
    String? description,
  }) async {
    final config = ref.readConfig;
    final repo = ref.read(szurubooruClientProvider(config));
    try {
      final newItems = await repo.getPools(
        offset: pageKey,
      );

      final isLastPage = newItems.isEmpty;
      if (isLastPage) {
        controller.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 100;
        controller.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      if (mounted) {
        controller.error = error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageGridSpacing = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridSpacing));
    final imageGridPadding = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridPadding));
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridAspectRatio = ref.watch(imageListingSettingsProvider
            .select((value) => value.imageGridAspectRatio)) -
        _kLabelOffset;

    final crossAxisCount = calculateGridCount(
      widget.constraints.maxWidth,
      gridSize,
    );

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: imageGridPadding),
      sliver: PagedSliverGrid(
        pagingController: controller,
        builderDelegate: PagedChildBuilderDelegate<PoolDto>(
          itemBuilder: (context, pool, index) =>
              SzurubooruPoolGridItem(pool: pool),
          firstPageProgressIndicatorBuilder: (context) => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: imageGridAspectRatio,
          mainAxisSpacing: imageGridSpacing,
          crossAxisSpacing: imageGridSpacing,
        ),
      ),
    );
  }
}

class SzurubooruPoolGridItem extends ConsumerWidget {
  const SzurubooruPoolGridItem({
    super.key,
    required this.pool,
  });

  final PoolDto pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PoolGridItem(
      image: PoolImage(pool: pool),
      onTap: () => goToPoolDetailPage(context, pool),
      total: pool.postCount ?? 0,
      name: pool.names?.firstOrNull ?? '???',
    );
  }
}

void goToPoolDetailPage(BuildContext context, PoolDto pool) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => PoolDetailPage.of(context, pool: pool),
  ));
}

void goToPoolPage(BuildContext context) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => const SzurubooruPoolPage(),
  ));
}

void goToAddToPoolPage(BuildContext context, List<Post> posts) {
  context.navigator.push(CupertinoPageRoute(
    builder: (_) => SzurubooruAddToPoolPage(posts: posts),
  ));
}

class PoolImage extends ConsumerWidget {
  const PoolImage({
    super.key,
    required this.pool,
  });

  final PoolDto pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBorderRadius = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageBorderRadius));
    final coverUrl = pool.posts?.firstOrNull?.thumbnailUrl;

    return LayoutBuilder(
      builder: (context, constraints) => coverUrl != null
          ? BooruImage(
              width: constraints.maxWidth,
              aspectRatio: 0.6,
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              borderRadius:
                  BorderRadius.all(Radius.circular(imageBorderRadius)),
            )
          : AspectRatio(
              aspectRatio: 0.6,
              child: Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.all(Radius.circular(imageBorderRadius)),
                ),
                child: const Center(
                  child: Text('No cover image'),
                ),
              ),
            ),
    );
  }
}

final poolPostIdsProvider = Provider.autoDispose.family<List<int>, PoolDto>(
  (ref, pool) {
    return pool.posts?.map((e) => e.id).whereNotNull().toList() ?? [];
  },
);

final _currentPoolProvider =
    StateProvider<PoolDto>((ref) => throw UnimplementedError());

class PoolDetailPage extends ConsumerWidget {
  const PoolDetailPage({
    super.key,
  });

  static Widget of(
    BuildContext context, {
    required PoolDto pool,
  }) =>
      CustomContextMenuOverlay(
        child: ProviderScope(
          overrides: [
            _currentPoolProvider.overrideWith((_) => pool),
          ],
          child: PoolDetailPage(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pool = ref.watch(_currentPoolProvider);

    return DanbooruInfinitePostIdList(
      ids: ref.watch(poolPostIdsProvider(pool)),
      sliverHeaders: [
        Builder(
          builder: (context) {
            return SliverAppBar(
              title: const Text('pool.pool').tr(),
              floating: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => SzurubooruPoolEditPage(
                        posts: pool.posts ?? [],
                        onSave: (posts) async {
                          final version = pool.version;
                          final id = pool.id;
                          if (version == null || id == null) {
                            return;
                          }

                          final newPool = await ref
                              .read(szurubooruClientProvider(ref.readConfig))
                              .updatePool(
                                id,
                                PoolUpdateRequest(
                                  version: version,
                                  postIds: posts
                                      .map((e) => e.id)
                                      .whereNotNull()
                                      .toList(),
                                ),
                              );

                          if (context.mounted) {
                            ref.read(_currentPoolProvider.notifier).state =
                                newPool;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              SzurubooruPostGridController.of(context)
                                  .refresh();
                              showSimpleSnackBar(
                                context: context,
                                content: Text('Pool updated'),
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class SzurubooruPoolEditPage extends StatefulWidget {
  const SzurubooruPoolEditPage({
    super.key,
    required this.posts,
    required this.onSave,
  });

  final List<MicroPostDto> posts;
  final void Function(List<MicroPostDto> posts) onSave;

  @override
  State<SzurubooruPoolEditPage> createState() => _SzurubooruPoolEditPageState();
}

class _SzurubooruPoolEditPageState extends State<SzurubooruPoolEditPage> {
  late final List<MicroPostDto> posts = widget.posts;

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final post = posts.removeAt(oldIndex);
    posts.insert(newIndex, post);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit pool'),
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
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            return Container(
              key: ValueKey(post.id),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  LimitedBox(
                    maxWidth: 50,
                    child: BooruImage(
                      fit: BoxFit.cover,
                      imageUrl: post.thumbnailUrl ?? '',
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
                  const SizedBox(width: 36),
                ],
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

//FIXME: need to create a generic version of this widget
class DanbooruInfinitePostIdList extends ConsumerStatefulWidget {
  const DanbooruInfinitePostIdList({
    super.key,
    required this.ids,
    this.sliverHeaders,
  });

  final List<int> ids;
  final List<Widget>? sliverHeaders;

  @override
  ConsumerState<DanbooruInfinitePostIdList> createState() =>
      _DanbooruInfinitePostIdListState();
}

class _DanbooruInfinitePostIdListState
    extends ConsumerState<DanbooruInfinitePostIdList> {
  List<int> paginate(List<int> ids, int page, int perPage) {
    final start = (page - 1) * perPage;
    var end = start + perPage;

    // if start is greater than the length of the list, return empty list
    if (start >= ids.length) {
      return [];
    }

    // if end is greater than the length of the list, set end to the length of the list
    if (end > ids.length) {
      end = ids.length;
    }

    return ids.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final perPage = ref.watch(
        imageListingSettingsProvider.select((value) => value.postsPerPage));
    final repo = ref.watch(szurubooruPostRepoProvider(ref.watchConfig));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(
          ($) async {
            final ids = paginate(widget.ids, page, perPage);
            if (ids.isEmpty) {
              return <Post>[].toResult(
                total: widget.ids.length,
              );
            }

            final idString = ids.join(',');
            final posts = await $(repo.getPosts('id:$idString', 1));

            // sort the posts based on the order of the ids
            final ordered = <Post>[];

            for (final id in ids) {
              final post =
                  posts.posts.firstWhereOrNull((post) => post.id == id);
              if (post != null) {
                ordered.add(post);
              }
            }

            return ordered.toResult(
              total: widget.ids.length,
            );
          },
        ),
        builder: (context, controller, errors) => SzurubooruPostGridController(
          controller: controller,
          child: InfinitePostListScaffold(
            errors: errors,
            controller: controller,
            sliverHeaders: [
              if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
            ],
          ),
        ),
      ),
    );
  }
}

class SzurubooruPostGridController extends InheritedWidget {
  const SzurubooruPostGridController({
    super.key,
    required this.controller,
    required super.child,
  });

  final PostGridController<Post> controller;

  static PostGridController<Post> of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SzurubooruPostGridController>();

    if (provider == null) {
      throw Exception('No SzurubooruPostGridController found in context');
    }

    return provider.controller;
  }

  @override
  bool updateShouldNotify(SzurubooruPostGridController oldWidget) {
    return controller != oldWidget.controller;
  }
}
