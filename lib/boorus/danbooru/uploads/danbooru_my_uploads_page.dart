// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/uploads/uploads.dart';
import 'package:boorusama/boorus/danbooru/users/users_provider.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/users/users.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/filesize.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

enum UploadTabType {
  posted,
  unposted,
}

class DanbooruUploadsPage extends ConsumerWidget {
  const DanbooruUploadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return BooruConfigAuthFailsafe(
      child: ref.watch(danbooruCurrentUserProvider(config)).maybeWhen(
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
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruMyUploadsPageState();
}

final _danbooruShowUploadHiddenProvider =
    StateProvider.autoDispose<bool>((ref) => false);

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
    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Uploads'),
          actions: [
            BooruPopupMenuButton(
              onSelected: (value) {
                switch (value) {
                  case 'show_hidden':
                    ref.read(_danbooruShowUploadHiddenProvider.notifier).state =
                        true;
                    break;
                  case 'hide_hidden':
                    ref.read(_danbooruShowUploadHiddenProvider.notifier).state =
                        false;
                    break;
                }
              },
              itemBuilder: {
                if (!ref.watch(_danbooruShowUploadHiddenProvider))
                  'show_hidden': const Text('Show hidden')
                else
                  'hide_hidden': const Text('Hide hidden'),
              },
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
    final settings = ref.watch(imageListingSettingsProvider);

    return PostScope(
      fetcher: (page) => TaskEither.Do(
        ($) async {
          final uploads =
              await ref.read(danbooruUploadRepoProvider(config)).getUploads(
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
      builder: (context, controller, errors) => LayoutBuilder(
          builder: (context, constraints) =>
              ref.watch(danbooruUploadHideMapProvider).maybeWhen(
                    data: (data) => _buildGrid(
                      controller,
                      settings,
                      constraints,
                      errors,
                      data,
                    ),
                    orElse: () => const SizedBox.shrink(),
                  )),
    );
  }

  void _changeVisibility(int id, bool visible) {
    ref
        .read(danbooruUploadHideMapProvider.notifier)
        .changeVisibility(id, visible);
  }

  Widget _buildGrid(
    PostGridController<DanbooruUploadPost> controller,
    ImageListingSettings settings,
    BoxConstraints constraints,
    BooruError? errors,
    Map<int, bool> hideMap,
  ) {
    final showHidden = ref.watch(_danbooruShowUploadHiddenProvider);

    return PostGrid(
      //TODO: this is broken, need to be integrated with the new filter system using the post grid controller
      blacklistedIdString: showHidden ? null : hideMap.keys.toSet().join('\n'),
      controller: controller,
      scrollController: _autoScrollController,
      body: SliverPostGrid(
        postController: controller,
        multiSelectController: null,
        constraints: constraints,
        itemBuilder: (context, index, post) {
          final isHidden = hideMap[post.id] == true;

          return Stack(
            children: [
              ContextMenuRegion(
                contextMenu: GenericContextMenu(
                  buttonConfigs: [
                    ContextMenuButtonConfig(
                      'Hide',
                      onPressed: () {
                        _changeVisibility(post.id, false);
                      },
                    ),
                  ],
                ),
                child: DanbooruImageGridItem(
                  onTap: () {
                    if (widget.type == UploadTabType.unposted) {
                      goToTagEditUploadPage(
                        context,
                        post: post,
                        uploadId: post.uploadId,
                        //TODO: Refresh later
                        // onSubmitted: () => controller.refresh(),
                      );
                    }
                  },
                  post: post,
                  hideOverlay: false,
                  autoScrollOptions: AutoScrollOptions(
                    controller: _autoScrollController,
                    index: index,
                  ),
                  enableFav: false,
                  image: ConditionalParentWidget(
                    condition: isHidden,
                    conditionalBuilder: (child) => Stack(
                      children: [
                        child,
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.applyOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    child: BooruImage(
                      aspectRatio: post.aspectRatio,
                      imageUrl:
                          post.thumbnailFromImageQuality(settings.imageQuality),
                      borderRadius: BorderRadius.circular(
                        settings.imageBorderRadius,
                      ),
                      forceFill:
                          settings.imageListType == ImageListType.standard,
                      placeholderUrl: post.thumbnailImageUrl,
                      // null, // Will cause error sometimes, disabled for now
                    ),
                  ),
                ),
              ),
              if (isHidden)
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
                            color: Colors.black.applyOpacity(0.7),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: WebsiteLogo(url: source.faviconUrl),
                        ),
                        () => const SizedBox.shrink(),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.black.applyOpacity(0.7),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
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
                          color: Colors.black.applyOpacity(0.7),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
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
        error: errors,
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
          color: Colors.black.applyOpacity(0.7),
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
          color: Colors.black.applyOpacity(0.8),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${post.postedCount}',
                style: context.textTheme.bodySmall,
              ),
              TextSpan(
                text: ' / ',
                style: context.textTheme.bodySmall,
              ),
              TextSpan(
                text: '${post.mediaAssetCount}',
                style: context.textTheme.bodySmall,
              ),
              TextSpan(
                text: ' posted',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploaderChip(BuildContext context, DanbooruUploadPost post) {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surface.applyOpacity(0.8),
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
                          style: context.textTheme.bodySmall,
                        ),
                        TextSpan(
                          text: uploader.name,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: uploader.level.toColor(context),
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
