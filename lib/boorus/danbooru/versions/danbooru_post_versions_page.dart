// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/versions/versions.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'tag_edit_history_card.dart';

class DanbooruPostVersionsPage extends ConsumerStatefulWidget {
  const DanbooruPostVersionsPage({
    super.key,
    required this.postId,
    required this.previewUrl,
  });

  final int postId;
  final String previewUrl;

  @override
  ConsumerState<DanbooruPostVersionsPage> createState() =>
      _DanbooruPostVersionsPageState();
}

class _DanbooruPostVersionsPageState
    extends ConsumerState<DanbooruPostVersionsPage> {
  @override
  Widget build(BuildContext context) {
    final versions = ref.watch(danbooruPostVersionsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: BooruImage(
                imageUrl: widget.previewUrl,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          const SliverSizedBox(
            height: 16,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            sliver: versions.when(
              data: (data) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TagEditHistoryCard(
                    version: data[index],
                    onUserTap: () => goToUserDetailsPage(
                      ref,
                      context,
                      uid: data[index].updater.id,
                      username: data[index].updater.name,
                    ),
                  ),
                  childCount: data.length,
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: const SizedBox(
                      height: 12,
                      width: 12,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Center(
                  child: Text(error.toString()),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
