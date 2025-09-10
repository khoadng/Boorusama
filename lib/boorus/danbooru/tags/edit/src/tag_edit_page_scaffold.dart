// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/settings/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/display.dart';
import '../../../../../foundation/scrolling.dart';
import 'providers/tag_edit_notifier.dart';
import 'tag_edit_content.dart';
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
                              child: widget.content,
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
      data: Theme.of(context).copyWith(
        focusColor: Theme.of(context).colorScheme.primary,
      ),
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            color: Theme.of(context).colorScheme.onSurface,
            thickness: 4,
            size: 75,
            highlightedColor: Theme.of(context).colorScheme.primary,
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
            'content' => widget.content,
            _ => const SizedBox.shrink(),
          },
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
      child: BooruImage(
        config: ref.watchConfigAuth,
        imageUrl: params.imageUrl,
        fit: BoxFit.contain,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}
