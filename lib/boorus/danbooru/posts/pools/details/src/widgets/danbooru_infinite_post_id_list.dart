// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../../core/configs/ref.dart';
import '../../../../../../../core/posts/listing/providers.dart';
import '../../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../../core/posts/post/post.dart';
import '../../../../../../../core/settings/data/listing_provider.dart';
import '../../../../../../../core/widgets/widgets.dart';
import '../../../../listing/widgets.dart';
import '../../../../post/post.dart';
import '../../../../post/providers.dart';

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
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );
    final repo = ref.watch(danbooruPostRepoProvider(ref.watchConfigSearch));

    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(
          ($) async {
            final ids = paginate(widget.ids, page, perPage);
            if (ids.isEmpty) {
              return <DanbooruPost>[].toResult(
                total: widget.ids.length,
              );
            }

            final idString = ids.join(',');
            final posts = await $(repo.getPosts('id:$idString', 1));

            // sort the posts based on the order of the ids
            final ordered = <DanbooruPost>[];

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
        builder: (context, controller) => DanbooruPostGridController(
          controller: controller,
          child: PostGrid(
            controller: controller,
            itemBuilder:
                (context, index, multiSelectController, scrollController) =>
                    DefaultDanbooruImageGridItem(
              index: index,
              multiSelectController: multiSelectController,
              autoScrollController: scrollController,
              controller: controller,
            ),
            sliverHeaders: [
              if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
            ],
          ),
        ),
      ),
    );
  }
}

// InheritedWidget to provide danbooru post grid controller to its children
class DanbooruPostGridController extends InheritedWidget {
  const DanbooruPostGridController({
    super.key,
    required this.controller,
    required super.child,
  });

  final PostGridController<DanbooruPost> controller;

  static PostGridController<DanbooruPost> of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<DanbooruPostGridController>();

    if (provider == null) {
      throw Exception('DanbooruPostGridControllerProvider not found');
    }

    return provider.controller;
  }

  @override
  bool updateShouldNotify(DanbooruPostGridController oldWidget) {
    return controller != oldWidget.controller;
  }
}
