// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/images/interactive_booru_image.dart';
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/scrolling.dart';
import 'package:boorusama/router.dart';
import '../../posts/post/danbooru_post.dart';
import '../shared/tag_list_notifier.dart';
import 'providers.dart';
import 'tag_edit_content.dart';
import 'tag_edit_notifier.dart';
import 'tag_edit_view_controller.dart';
import 'widgets/tag_edit_rating_selector_section.dart';

class TagEditPage extends ConsumerWidget {
  const TagEditPage({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final tags = ref.watch(danbooruTagListProvider(config));
    final initialRating =
        tags.containsKey(post.id) ? tags[post.id]!.rating : post.rating;
    final effectiveTags =
        tags.containsKey(post.id) ? tags[post.id]!.allTags : post.tags.toSet();

    return ProviderScope(
      overrides: [
        tagEditProvider.overrideWith(
          () => TagEditNotifier(
            initialTags: effectiveTags,
            postId: post.id,
            imageAspectRatio: post.aspectRatio ?? 1,
            imageUrl: post.url720x720,
            initialRating: initialRating,
          ),
        ),
      ],
      child: TagEditPageInternal(
        submitButton: const TagEditSubmitButton(),
        ratingSelector: TagEditRatingSelectorSection(
          rating: initialRating,
          onChanged: (value) {
            ref
                .read(selectedTagEditRatingProvider(initialRating).notifier)
                .state = value;
          },
        ),
      ),
    );
  }
}

class TagEditSubmitButton extends ConsumerWidget {
  const TagEditSubmitButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(tagEditProvider.notifier);
    final initialRating = notifier.initialRating;
    final postId = notifier.postId;
    final addedTags =
        ref.watch(tagEditProvider.select((value) => value.toBeAdded));
    final removedTags =
        ref.watch(tagEditProvider.select((value) => value.toBeRemoved));
    final rating = ref.watch(selectedTagEditRatingProvider(initialRating));

    return TextButton(
      onPressed: (addedTags.isNotEmpty ||
              removedTags.isNotEmpty ||
              rating != initialRating)
          ? () {
              ref
                  .read(danbooruTagListProvider(ref.readConfigAuth).notifier)
                  .setTags(
                    postId,
                    addedTags: addedTags.toList(),
                    removedTags: removedTags.toList(),
                    rating: rating != initialRating ? rating : null,
                  );
              context.pop();
            }
          : null,
      child: const Text('Submit'),
    );
  }
}

class TagEditPageInternal extends ConsumerStatefulWidget {
  const TagEditPageInternal({
    super.key,
    required this.ratingSelector,
    required this.submitButton,
    this.sourceBuilder,
  });

  final Widget ratingSelector;
  final Widget submitButton;

  final Widget Function()? sourceBuilder;

  @override
  ConsumerState<TagEditPageInternal> createState() =>
      _TagEditPageInternalState();
}

class _TagEditPageInternalState extends ConsumerState<TagEditPageInternal> {
  final scrollController = ScrollController();
  final viewController = TagEditViewController();

  @override
  void initState() {
    super.initState();
    viewController.addListener(_onViewChanged);
  }

  void _onViewChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    viewController.removeListener(_onViewChanged);

    scrollController.dispose();
    viewController.dispose();
  }

  void _pop() {
    if (!mounted) return;

    final expandMode =
        ref.read(tagEditProvider.select((value) => value.expandMode));

    if (expandMode != null) {
      ref.read(tagEditProvider.notifier).setExpandMode(null);
      viewController.setDefaultSplit();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expandMode =
        ref.watch(tagEditProvider.select((value) => value.expandMode));

    ref.listen(
      tagEditProvider.select((value) => value.tags),
      (prev, current) {
        if ((prev?.length ?? 0) < (current.length)) {
          // Hacky way to scroll to the end of the list, somehow if it is currently on top, it won't scroll to last item
          final offset = scrollController.offset ==
                  scrollController.position.maxScrollExtent
              ? 0
              : scrollController.position.maxScrollExtent / current.length;

          WidgetsBinding.instance.addPostFrameCallback(
            (_) {
              if (!mounted || !scrollController.hasClients) return;

              scrollController.animateToWithAccessibility(
                scrollController.position.maxScrollExtent + offset,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                reduceAnimations: ref.read(settingsProvider).reduceAnimations,
              );
            },
          );

          Future.delayed(
            const Duration(milliseconds: 200),
            () {},
          );
        }
      },
    );

    ref.listen(
      tagEditProvider.select((value) => value.expandMode),
      (prev, current) {
        if (prev != current) {
          viewController.setMaxSplit(context);
        }
      },
    );

    return PopScope(
      canPop: expandMode == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        _pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: kPreferredLayout.isMobile && expandMode != null,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _pop,
            icon: const Icon(Symbols.arrow_back),
          ),
          actions: [
            widget.submitButton,
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: Screen.of(context).size == ScreenSize.small
                ? Column(
                    children: [
                      Expanded(
                        child: _buildSplit(),
                      ),
                      TagEditExpandContent(
                        viewController: viewController,
                        maxHeight: constraints.maxHeight,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(
                        child: TagEditImageSection(),
                      ),
                      const VerticalDivider(
                        width: 4,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        width: min(
                          MediaQuery.of(context).size.width * 0.4,
                          400,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: TagEditContent(
                                ratingSelector: widget.ratingSelector,
                                scrollController: scrollController,
                                sourceBuilder: widget.sourceBuilder,
                              ),
                            ),
                            TagEditExpandContent(
                              viewController: viewController,
                              maxHeight: constraints.maxHeight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplit() {
    return Theme(
      data: context.theme.copyWith(
        focusColor: context.colorScheme.primary,
      ),
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            color: context.colorScheme.onSurface,
            thickness: 4,
            size: 75,
            highlightedColor: context.colorScheme.primary,
          ),
        ),
        child: MultiSplitView(
          axis: Axis.vertical,
          controller: viewController.splitController,
          builder: (context, area) => switch (area.data) {
            'image' => const Column(
                children: [
                  Expanded(
                    child: TagEditImageSection(),
                  ),
                  Divider(
                    thickness: 1,
                    height: 4,
                  ),
                ],
              ),
            'content' => TagEditContent(
                ratingSelector: widget.ratingSelector,
                scrollController: scrollController,
                sourceBuilder: widget.sourceBuilder,
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _Image extends ConsumerWidget {
  const _Image();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifer = ref.watch(tagEditProvider.notifier);
    return InteractiveBooruImage(
      useHero: false,
      heroTag: '',
      aspectRatio: notifer.imageAspectRatio,
      imageUrl: notifer.imageUrl,
    );
  }
}

class TagEditImageSection extends StatelessWidget {
  const TagEditImageSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxHeight > 80
          ? const _Image()
          : SizedBox(
              height: constraints.maxHeight - 4,
            ),
    );
  }
}
