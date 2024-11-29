// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({
    super.key,
    this.useAppBarPadding = true,
    required this.sliverOverviews,
  });

  final bool useAppBarPadding;
  final List<Widget> sliverOverviews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomScrollView(
        primary: false,
        slivers: [
          SliverSizedBox(
            height:
                useAppBarPadding ? MediaQuery.viewPaddingOf(context).top : 0,
          ),
          ...sliverOverviews,
          const SliverSizedBox(height: kBottomNavigationBarHeight + 20),
        ],
      ),
    );
  }
}

class ExplorePageDesktopController extends ChangeNotifier {
  final ValueNotifier<String?> selectedCategory = ValueNotifier(null);

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  void back() {
    selectedCategory.value = null;
  }
}

class ExplorePageDesktop extends ConsumerStatefulWidget {
  const ExplorePageDesktop({
    super.key,
    required this.sliverOverviews,
    required this.details,
    this.controller,
  });

  final List<Widget> sliverOverviews;
  final Widget details;
  final ExplorePageDesktopController? controller;

  @override
  ConsumerState<ExplorePageDesktop> createState() => _ExplorePageDesktopState();
}

class _ExplorePageDesktopState extends ConsumerState<ExplorePageDesktop> {
  late final controller = widget.controller ?? ExplorePageDesktopController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    controller.selectedCategory.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {
      selectedCategory = controller.selectedCategory.value;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }

    controller.selectedCategory.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Offstage(
          offstage: selectedCategory != null,
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.viewPaddingOf(context).top,
            ),
            child: CustomScrollView(
              primary: false,
              slivers: [
                ...widget.sliverOverviews,
              ],
            ),
          ),
        ),
        Offstage(
          offstage: selectedCategory == null,
          child: widget.details,
        ),
      ],
    );
  }
}

class ExploreList extends ConsumerWidget {
  const ExploreList({
    super.key,
    required this.posts,
  });

  final List<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = context.screen.size == ScreenSize.small ? 200.0 : 250.0;
    final config = ref.watchConfigAuth;

    return ref.watch(blacklistTagsProvider(config)).when(
          data: (blacklistedTags) {
            final filteredPosts = posts
                .where((post) =>
                    !blacklistedTags.any((tag) => post.tags.contains(tag)))
                .toList();

            return filteredPosts.isNotEmpty
                ? _buildList(height, filteredPosts, ref)
                : _buildEmpty(height);
          },
          error: (error, _) => _buildList(height, [], ref),
          loading: () => _buildEmpty(height),
        );
  }

  Widget _buildList(
    double height,
    List<Post> filteredPosts,
    WidgetRef ref,
  ) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];

          return ExplicitContentBlockOverlay(
            rating: post.rating,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () => goToPostDetailsPageFromPosts(
                  context: context,
                  posts: filteredPosts,
                  initialIndex: index,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BooruImage(
                      aspectRatio: post.aspectRatio,
                      imageUrl: defaultPostImageUrlBuilder(ref)(post),
                      placeholderUrl: post.thumbnailImageUrl,
                    ),
                    if (post.isAnimated)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: VideoPlayDurationIcon(
                          duration: post.duration,
                          hasSound: post.hasSound,
                        ),
                      ),
                    Positioned.fill(
                      child: ShadowGradientOverlay(
                        alignment: Alignment.bottomCenter,
                        colors: [
                          const Color(0xC2000000),
                          Colors.black12.applyOpacity(0),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 5,
                      bottom: 1,
                      child: Text(
                        '${index + 1}',
                        style: context.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: filteredPosts.length,
      ),
    );
  }

  Widget _buildEmpty(double height) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: createRandomPlaceholderContainer(context),
        ),
      ),
    );
  }
}
