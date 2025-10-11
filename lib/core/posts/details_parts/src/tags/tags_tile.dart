// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../search/search/routes.dart';
import '../../../../tags/categories/tag_category.dart';
import '../../../../tags/tag/providers.dart';
import '../../../../tags/tag/tag.dart';
import '../../../../tags/tag/widgets.dart';
import '../../../details/details.dart';
import '../../../post/post.dart';
import 'basic_tags_tile.dart';
import 'raw_tags_tile.dart';

class DefaultInheritedTagsTile<T extends Post> extends ConsumerStatefulWidget {
  const DefaultInheritedTagsTile({
    super.key,
    this.onTagTap,
  });

  final void Function(Tag tag)? onTagTap;

  @override
  ConsumerState<DefaultInheritedTagsTile<T>> createState() =>
      _DefaultInheritedTagsTileState<T>();
}

class _DefaultInheritedTagsTileState<T extends Post>
    extends ConsumerState<DefaultInheritedTagsTile<T>> {
  var expanded = false;
  Object? error;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<T>(context);
    final auth = ref.watchConfigAuth;
    final params = (auth, post);

    if (expanded) {
      ref.listen(
        tagGroupsProvider(params),
        (previous, next) {
          next.when(
            data: (data) {
              if (!mounted) return;

              if (data == null || (data.isEmpty && post.tags.isNotEmpty)) {
                // Just a dummy data so the check below will branch into the else block
                setState(() => error = 'No tags found');
              }
            },
            loading: () {},
            error: (error, stackTrace) {
              if (!mounted) return;
              setState(() => this.error = error);
            },
          );
        },
      );
    }

    return SliverToBoxAdapter(
      child: error == null
          ? TagsTile(
              auth: auth,
              tags: expanded
                  ? ref.watch(tagGroupsProvider(params)).valueOrNull
                  : null,
              post: post,
              onExpand: () => setState(() => expanded = true),
              onCollapse: () {
                // Don't set expanded to false to prevent rebuilding the tags list
                setState(() => error = null);
              },
              onTagTap: widget.onTagTap,
            )
          : BasicTagsTile(
              post: post,
              tags: post.tags,
              auth: auth,
              onTagTap: (tag) => widget.onTagTap?.call(
                Tag.noCount(
                  name: tag,
                  category: TagCategory.unknown(),
                ),
              ),
            ),
    );
  }
}

class TagsTile extends StatelessWidget {
  const TagsTile({
    required this.post,
    required this.tags,
    required this.auth,
    super.key,
    this.onExpand,
    this.onCollapse,
    this.initialExpanded = false,
    this.tagColorBuilder,
    this.padding,
    this.onTagTap,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function()? onCollapse;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;
  final Color? Function(Tag tag)? tagColorBuilder;
  final EdgeInsetsGeometry? padding;
  final BooruConfigAuth auth;
  final void Function(Tag tag)? onTagTap;

  @override
  Widget build(BuildContext context) {
    final count = post.tags.isEmpty
        ? tags?.expand((tag) => tag.tags).length
        : post.tags.length;

    return RawTagsTile(
      title: RawTagsTileTitle(
        auth: auth,
        post: post,
        count: count,
      ),
      initiallyExpanded: initialExpanded,
      onExpansionChanged: (value) =>
          value ? onExpand?.call() : onCollapse?.call(),
      children: [
        PostTagList(
          padding: padding,
          tags: tags,
          itemBuilder: (context, tag) => GeneralTagContextMenu(
            tag: tag.rawName,
            child: Consumer(
              builder: (_, ref, _) => PostTagListChip(
                tag: tag,
                auth: auth,
                onTap: onTagTap != null
                    ? () => onTagTap?.call(tag)
                    : () => goToSearchPage(ref, tag: tag.rawName),
                color: tagColorBuilder?.call(tag),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
