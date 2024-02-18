// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/router.dart';

class ArtistPostList extends ConsumerWidget {
  const ArtistPostList({
    super.key,
    required this.artists,
    required this.builder,
  });

  final List<String> artists;
  final Widget Function(String tag) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tag = artists[index];
          return Column(
            children: [
              ListTile(
                visualDensity: VisualDensity.compact,
                onTap: () => goToArtistPage(context, tag),
                title: Text(tag.replaceAll('_', ' ')),
                trailing: const Icon(
                  Symbols.arrow_right_alt,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: builder(tag),
              ),
            ],
          );
        },
        childCount: artists.length,
      ),
    );
  }
}
