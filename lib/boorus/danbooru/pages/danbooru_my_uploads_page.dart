// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/uploads/uploads.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

enum UploadTabType {
  posted,
  unposted,
}

class DanbooruMyUploadsPage extends ConsumerStatefulWidget {
  const DanbooruMyUploadsPage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruMyUploadsPageState();
}

class _DanbooruMyUploadsPageState extends ConsumerState<DanbooruMyUploadsPage>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploads'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicatorColor: context.colorScheme.onBackground,
              labelColor: context.colorScheme.onBackground,
              unselectedLabelColor:
                  context.colorScheme.onBackground.withOpacity(0.5),
              tabs: const [
                Tab(text: 'Posted'),
                Tab(text: 'Unposted'),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    _buildTab(UploadTabType.posted),
                    _buildTab(UploadTabType.unposted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(UploadTabType type) {
    return DanbooruUploadGrid(
      type: type,
      userId: widget.userId,
    );
  }
}

class DanbooruUploadGrid extends ConsumerStatefulWidget {
  const DanbooruUploadGrid({
    super.key,
    required this.userId,
    required this.type,
  });

  final UploadTabType type;
  final int userId;

  @override
  ConsumerState<DanbooruUploadGrid> createState() => _DanbooruUploadGridState();
}

class _DanbooruUploadGridState extends ConsumerState<DanbooruUploadGrid> {
  late final AutoScrollController _autoScrollController =
      AutoScrollController();

  @override
  void dispose() {
    super.dispose();
    _autoScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final settings = ref.watch(settingsProvider);

    return PostScope(
      fetcher: (page) => TaskEither.Do(
        ($) async {
          final uploads = await ref
              .read(danbooruUploadRepoProvider(config))
              .getUploads(
                page: page,
                userId: widget.userId,
                isPosted: switch (widget.type) {
                  UploadTabType.posted => true,
                  UploadTabType.unposted => false,
                },
              )
              .then((value) => value.map((e) => e.previewPost).toList());

          return uploads;
        },
      ),
      builder: (context, controller, errors) => LayoutBuilder(
        builder: (context, constraints) => PostGrid(
          controller: controller,
          scrollController: _autoScrollController,
          itemBuilder: (context, items, index) {
            final post = items[index];

            return DanbooruImageGridItem(
              post: post,
              hideOverlay: false,
              autoScrollOptions: AutoScrollOptions(
                controller: _autoScrollController,
                index: index,
              ),
              enableFav: false,
              image: BooruImage(
                aspectRatio: post.aspectRatio,
                imageUrl: post.thumbnailFromSettings(settings),
                borderRadius: BorderRadius.circular(
                  settings.imageBorderRadius,
                ),
                forceFill: settings.imageListType == ImageListType.standard,
                placeholderUrl: post.thumbnailImageUrl,
                // null, // Will cause error sometimes, disabled for now
              ),
            );
          },
          bodyBuilder: (context, itemBuilder, refreshing, data) {
            return SliverPostGrid(
              constraints: constraints,
              itemBuilder: itemBuilder,
              refreshing: refreshing,
              error: errors,
              data: data,
              onRetry: () => controller.refresh(),
            );
          },
        ),
      ),
    );
  }
}
