// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/ref.dart';
import '../../../../search/search/routes.dart';
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
  });

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
    final params = (ref.watchConfigAuth, post);

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
              tags: expanded
                  ? ref.watch(tagGroupsProvider(params)).valueOrNull
                  : null,
              post: post,
              onExpand: () => setState(() => expanded = true),
              onCollapse: () {
                // Don't set expanded to false to prevent rebuilding the tags list
                setState(() => error = null);
              },
            )
          : BasicTagsTile(
              post: post,
              auth: ref.watchConfigAuth,
            ),
    );
  }
}

class TagsTile extends StatelessWidget {
  const TagsTile({
    required this.post,
    required this.tags,
    super.key,
    this.onExpand,
    this.onCollapse,
    this.initialExpanded = false,
    this.tagColorBuilder,
    this.padding,
  });

  final Post post;
  final void Function()? onExpand;
  final void Function()? onCollapse;
  final bool initialExpanded;
  final List<TagGroupItem>? tags;
  final Color? Function(Tag tag)? tagColorBuilder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final count = post.tags.isEmpty
        ? tags?.expand((tag) => tag.tags).length
        : post.tags.length;

    return RawTagsTile(
      title: RawTagsTileTitle(
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
              builder: (_, ref, __) => PostTagListChip(
                tag: tag,
                auth: ref.watchConfigAuth,
                onTap: () => goToSearchPage(context, tag: tag.rawName),
                color: tagColorBuilder != null ? tagColorBuilder!(tag) : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
