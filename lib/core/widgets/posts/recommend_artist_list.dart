// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'recommend_section.dart';

class RecommendArtistList<T extends Post> extends StatelessWidget {
  const RecommendArtistList({
    super.key,
    required this.recommends,
    required this.onHeaderTap,
    required this.onTap,
    required this.imageUrl,
  });

  final List<Recommend<T>> recommends;
  final void Function(int index) onHeaderTap;
  final void Function(int recommendIndex, int postIndex) onTap;
  final String Function(T item) imageUrl;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final r = recommends[index];

          if (r.posts.isEmpty) return const SizedBox();

          return RecommendPostSection(
            header: ListTile(
              onTap: () => onHeaderTap(index),
              title: Text(r.title),
              trailing: const Icon(
                Symbols.arrow_right_alt,
              ),
            ),
            posts: r.posts,
            onTap: (postIdx) => onTap(index, postIdx),
            imageUrl: imageUrl,
          );
        },
        childCount: recommends.length,
      ),
    );
  }
}
