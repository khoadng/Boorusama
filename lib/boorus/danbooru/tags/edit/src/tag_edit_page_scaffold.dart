// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/images/providers.dart';
import '../../../../../core/posts/details/widgets.dart';
import '../../../../../core/settings/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/display.dart';
import '../../../../../foundation/scrolling.dart';
import 'providers/tag_edit_notifier.dart';
import 'tag_edit_content.dart';
import 'tag_edit_split_layout.dart';
import 'tag_edit_view_controller.dart';

class TagEditPageScaffold extends ConsumerStatefulWidget {
  const TagEditPageScaffold({
    required this.submitButton,
    required this.content,
    required this.scrollController,
    super.key,
  });

  final Widget submitButton;
  final Widget content;
  final ScrollController scrollController;

  @override
  ConsumerState<TagEditPageScaffold> createState() =>
      _TagEditPageScaffoldState();
}

class _TagEditPageScaffoldState extends ConsumerState<TagEditPageScaffold> {
  final viewController = TagEditViewController();
  late final scrollController = widget.scrollController;

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

    viewController
      ..removeListener(_onViewChanged)
      ..dispose();
  }

  void _pop(TagEditParams params) {
    if (!mounted) return;

    final expandMode = ref.read(
      tagEditProvider(params).select((value) => value.expandMode),
    );

    if (expandMode != null) {
      ref.read(tagEditProvider(params).notifier).setExpandMode(null);
      viewController.setDefaultSplit();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = TagEditParamsProvider.of(context);
    final expandMode = ref.watch(
      tagEditProvider(params).select((value) => value.expandMode),
    );

    ref
      ..listen(
        tagEditProvider(params).select((value) => value.tags),
        (prev, current) {
          if ((prev?.length ?? 0) < (current.length)) {
            // Hacky way to scroll to the end of the list, somehow if it is currently on top, it won't scroll to last item
            final offset =
                scrollController.offset ==
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
      )
      ..listen(
        tagEditProvider(params).select((value) => value.expandMode),
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

        _pop(params);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: kPreferredLayout.isMobile && expandMode != null,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => _pop(params),
            icon: const Icon(Symbols.arrow_back),
          ),
          actions: [
            widget.submitButton,
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final expandContent = TagEditExpandContent(
                viewController: viewController,
                maxHeight: constraints.maxHeight,
              );

              return Screen.of(context).size == ScreenSize.small
                  ? Column(
                      children: [
                        Expanded(
                          child: TagEditSplitLayout(
                            viewController: viewController,
                            imageBuilder: () => const TagEditImageSection(),
                            contentBuilder: (_) => widget.content,
                          ),
                        ),
                        expandContent,
                      ],
                    )
                  : TagEditSplitLayout(
                      viewController: viewController,
                      imageBuilder: () => const TagEditImageSection(),
                      contentBuilder: (_) => Column(
                        children: [
                          Expanded(child: widget.content),
                          expandContent,
                        ],
                      ),
                    );
            },
          ),
        ),
      ),
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

class _Image extends ConsumerWidget {
  const _Image();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = TagEditParamsProvider.of(context);

    return InteractiveViewerExtended(
      child: RawPostDetailsImage(
        post: params.post,
        config: ref.watchConfigAuth,
        imageUrlBuilder: (_) => params.imageUrl,
        thumbnailUrlBuilder: (_) => params.placeholderUrl,
        imageCacheManager: ref.watch(
          defaultImageCacheManagerProvider,
        ),
        fit: BoxFit.contain,
      ),
    );
  }
}
