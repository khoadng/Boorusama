// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../foundation/html.dart';
import '../../../configs/config/providers.dart';
import '../../../posts/listing/providers.dart';
import '../../../search/queries/types.dart';
import '../../../search/search/widgets.dart';
import '../../../themes/theme/types.dart';
import '../providers/suggestion_provider.dart';

class BookmarkSearchBar extends ConsumerStatefulWidget {
  const BookmarkSearchBar({
    required this.focusNode,
    required this.controller,
    required this.postController,
    super.key,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final PostGridController postController;

  @override
  ConsumerState<BookmarkSearchBar> createState() => _BookmarkSearchBarState();
}

class _BookmarkSearchBarState extends ConsumerState<BookmarkSearchBar> {
  final _overlay = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    _overlay.dispose();

    super.dispose();
  }

  void _onFocusChanged() {
    final focus = widget.focusNode.hasFocus;

    if (focus) {
      _overlay.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          height: kPreferredLayout.isDesktop ? 34 : null,
          child: ValueListenableBuilder(
            valueListenable: _overlay,
            builder: (_, overlay, _) {
              return ValueListenableBuilder(
                valueListenable: widget.controller,
                builder: (_, controller, _) {
                  return PortalTarget(
                    anchor: const Aligned(
                      follower: Alignment.topCenter,
                      target: Alignment.bottomCenter,
                    ),
                    portalFollower: _Overlay(
                      controller: widget.controller,
                      maxWidth: constraints.maxWidth,
                      onTapOutside: _disableOverlay,
                      onTap: (tag) {
                        widget.controller.text = replaceOrAppendTag(
                          widget.controller.text,
                          tag.tag,
                        );
                        _search();
                      },
                    ),
                    visible: overlay,
                    child: _buildSearchBar(controller),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _disableOverlay() {
    _overlay.value = false;
    widget.focusNode.unfocus();
  }

  void _search() {
    widget.postController.refresh();
    _disableOverlay();
  }

  Widget _buildSearchBar(TextEditingValue controller) {
    return BooruSearchBar(
      focus: widget.focusNode,
      controller: widget.controller,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Symbols.search),
      ),
      trailing: controller.text.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Symbols.clear),
                onTap: () {
                  widget.controller.clear();
                  _search();
                },
              ),
            )
          : const SizedBox.shrink(),
      onSubmitted: (value) {
        _search();
      },
    );
  }
}

class _Overlay extends ConsumerStatefulWidget {
  const _Overlay({
    required this.controller,
    required this.maxWidth,
    required this.onTap,
    required this.onTapOutside,
  });

  final TextEditingController controller;
  final double maxWidth;
  final ValueChanged<TagWithColor> onTap;
  final VoidCallback onTapOutside;

  @override
  ConsumerState<_Overlay> createState() => _OverlayState();
}

class _OverlayState extends ConsumerState<_Overlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuggestions();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _loadSuggestions();
  }

  void _loadSuggestions() {
    final config = ref.readConfigAuth;
    ref
        .read(tagSuggestionsProvider.notifier)
        .loadSuggestions(config, widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final scrimColor = Colors.black.withValues(alpha: 0.7);

    return Column(
      children: [
        ref
            .watch(tagSuggestionsProvider)
            .maybeWhen(
              data: (state) => state.suggestions.isNotEmpty
                  ? _SuggestionContainer(
                      scrimColor: scrimColor,
                      height: state.suggestions.length * 44,
                      maxWidth: widget.maxWidth,
                      child: ListView.builder(
                        itemCount: state.suggestions.length,
                        itemBuilder: (context, index) {
                          final tag = state.suggestions[index];

                          return _SuggestionItem(
                            tagWithColor: tag,
                            controller: widget.controller,
                            onTap: () {
                              widget.onTap(tag);
                            },
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
        Expanded(
          child: GestureDetector(
            onTap: widget.onTapOutside,
            child: Container(
              color: scrimColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionContainer extends StatelessWidget {
  const _SuggestionContainer({
    required this.scrimColor,
    required this.height,
    required this.maxWidth,
    required this.child,
  });

  final double maxWidth;
  final Color scrimColor;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scrimColor,
      child: Container(
        margin: const EdgeInsets.only(
          top: 4,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        height: height,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: min(MediaQuery.sizeOf(context).height * 0.8, 300),
        ),
        child: child,
      ),
    );
  }
}

class _SuggestionItem extends ConsumerWidget {
  const _SuggestionItem({
    required this.tagWithColor,
    required this.controller,
    required this.onTap,
  });

  final TagWithColor tagWithColor;
  final VoidCallback onTap;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = tagWithColor.tag;
    final color = tagWithColor.color;
    final count = tagWithColor.count;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
        child: IgnorePointer(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 36,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: kPreferredLayout.isMobile ? 4 : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (_, value, _) {
                      final lastTag =
                          value.text.split(' ').lastOrNull ?? value.text;

                      return AppHtml(
                        style: {
                          'p': Style(
                            fontSize: FontSize.medium,
                            color: color,
                            margin: Margins.zero,
                          ),
                          'b': Style(
                            fontWeight: FontWeight.w900,
                          ),
                        },
                        data:
                            '<p>${tag.replaceAll(lastTag, '<b>$lastTag</b>')}</p>',
                      );
                    },
                  ),
                ),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
