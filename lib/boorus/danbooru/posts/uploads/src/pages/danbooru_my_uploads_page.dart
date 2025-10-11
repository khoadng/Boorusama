// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../../core/config_widgets/website_logo.dart';
import '../../../../../../core/configs/auth/widgets.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/listing/providers.dart';
import '../../../../../../core/posts/listing/widgets.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/posts/sources/source.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../users/user/providers.dart';
import '../../../listing/widgets.dart';
import '../providers/providers.dart';
import '../providers/upload_hide_provider.dart';
import '../routes/route_utils.dart';
import '../types/danbooru_upload.dart';
import '../types/danbooru_upload_post.dart';

enum UploadTabType {
  posted,
  unposted,
}

class DanbooruUploadsPage extends ConsumerWidget {
  const DanbooruUploadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return BooruConfigAuthFailsafe(
      builder: (_) => ref
          .watch(danbooruCurrentUserProvider(config))
          .maybeWhen(
            data: (data) => data != null
                ? DanbooruMyUploadsPageInternal(
                    userId: data.id,
                  )
                : Scaffold(
                    appBar: AppBar(),
                    body: const Center(
                      child: Text('Unauthorized'),
                    ),
                  ),
            orElse: () => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
    );
  }
}

class DanbooruMyUploadsPageInternal extends ConsumerStatefulWidget {
  const DanbooruMyUploadsPageInternal({
    required this.userId,
    super.key,
  });

  final int userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruMyUploadsPageState();
}

class _DanbooruMyUploadsPageState
    extends ConsumerState<DanbooruMyUploadsPageInternal>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;
    final hideNofifier = ref.watch(
      danbooruUploadHideProvider(config).notifier,
    );

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Uploads'.hc),
          actions: [
            ref
                .watch(danbooruUploadHideProvider(config))
                .maybeWhen(
                  data: (state) => BooruPopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 'toggle_hidden':
                          hideNofifier.toggleShowHidden();
                      }
                    },
                    itemBuilder: {
                      'toggle_hidden': Text(
                        state.showHiddenUploads
                            ? 'Hide hidden'.hc
                            : 'Show hidden'.hc,
                      ),
                    },
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                controller: tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Unposted'),
                  Tab(text: 'Posted'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      _buildTab(UploadTabType.unposted),
                      _buildTab(UploadTabType.posted),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    required this.userId,
    required this.type,
    super.key,
  });

  final UploadTabType type;
  final int userId;

  @override
  ConsumerState<DanbooruUploadGrid> createState() => _DanbooruUploadGridState();
}

class _DanbooruUploadGridState extends ConsumerState<DanbooruUploadGrid> {
  late final _autoScrollController = AutoScrollController();

  @override
  void dispose() {
    _autoScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfigAuth;

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
              );

          return uploads.map((e) => e.previewPost).nonNulls.toList().toResult();
        },
      ),
      builder: (context, controller) => LayoutBuilder(
        builder: (context, constraints) => ref
            .watch(danbooruUploadHideProvider(config))
            .maybeWhen(
              data: (state) => _buildGrid(
                controller,
                constraints,
                state,
              ),
              orElse: () => const SizedBox.shrink(),
            ),
      ),
    );
  }

  void _changeVisibility(int id, bool visible) {
    ref
        .read(danbooruUploadHideProvider(ref.watchConfigAuth).notifier)
        .changeVisibility(id, visible);
  }

  Widget _buildGrid(
    PostGridController<DanbooruUploadPost> controller,
    BoxConstraints constraints,
    DanbooruUploadHideState hideState,
  ) {
    return PostGrid(
      controller: controller,
      itemBuilder: (context, index, scrollController, useHero) =>
          ValueListenableBuilder(
            valueListenable: controller.itemsNotifier,
            builder: (_, posts, _) {
              final post = posts[index];

              // Filter out hidden posts when showHiddenUploads is false
              if (!hideState.shouldShowInList(post.id)) {
                return const SizedBox.shrink();
              }

              final shouldShowOverlay = hideState.shouldShowOverlay(post.id);

              return Stack(
                children: [
                  DefaultDanbooruImageGridItem(
                    index: index,
                    autoScrollController: scrollController,
                    controller: controller,
                    useHero: useHero,
                    quickActionButton: const SizedBox.shrink(),
                    contextMenu: GenericContextMenu(
                      buttonConfigs: [
                        ContextMenuButtonConfig(
                          'Hide',
                          onPressed: () {
                            _changeVisibility(posts[index].id, false);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      if (widget.type == UploadTabType.unposted) {
                        goToTagEditUploadPage(
                          ref,
                          post: post,
                          uploadId: post.uploadId,
                          //TODO: Refresh later
                          // onSubmitted: () => controller.refresh(),
                        );
                      }
                    },
                    blockOverlay: shouldShowOverlay
                        ? BlockOverlayItem(
                            overlay: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.8),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {
                                      _changeVisibility(post.id, true);
                                    },
                                    icon: const Icon(Icons.visibility),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  if (widget.type == UploadTabType.unposted)
                    _buildUnpostedChip(post),
                  if (post.uploaderId != 0 &&
                      post.uploaderId != widget.userId &&
                      widget.type == UploadTabType.posted)
                    _buildUploaderChip(context, post),
                  if (post.mediaAssetCount > 1)
                    _buildCountChip(post)
                  else
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          post.source.whenWeb(
                            (source) => Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.all(1),
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              child: ConfigAwareWebsiteLogo(
                                url: source.url,
                              ),
                            ),
                            () => const SizedBox.shrink(),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: Text(
                              Filesize.parse(post.fileSize, round: 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: Text(
                              '${post.width.toInt()}x${post.height.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildCountChip(DanbooruUploadPost post) {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          children: [
            const Icon(
              FontAwesomeIcons.images,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '${post.mediaAssetCount}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpostedChip(DanbooruUploadPost post) {
    if (post.mediaAssetCount <= 1 || post.postedCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${post.postedCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: ' / ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: '${post.mediaAssetCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextSpan(
                text: ' posted',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploaderChip(BuildContext context, DanbooruUploadPost post) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Builder(
          builder: (context) {
            final uploader = post.uploader;
            return uploader != null
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'By ',
                          style: theme.textTheme.bodySmall,
                        ),
                        TextSpan(
                          text: uploader.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DanbooruUserColor.of(
                              context,
                            ).fromUser(uploader),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
