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
import '../../../configs/ref.dart';
import '../../../search/search/widgets.dart';
import '../../../theme.dart';
import '../providers/bookmark_provider.dart';
import '../providers/local_providers.dart';

class BookmarkSearchBar extends ConsumerStatefulWidget {
  const BookmarkSearchBar({
    required this.focusNode,
    required this.controller,
    super.key,
  });

  final FocusNode focusNode;
  final TextEditingController controller;

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
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    if (!hasBookmarks) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final suggestions = ref.watch(tagSuggestionsProvider).valueOrNull ?? [];
        final selectedTag = ref.watch(selectedTagsProvider);

        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          height: kPreferredLayout.isDesktop ? 34 : null,
          child: ValueListenableBuilder(
            valueListenable: _overlay,
            builder: (_, overlay, _) {
              return PortalTarget(
                anchor: const Aligned(
                  follower: Alignment.topCenter,
                  target: Alignment.bottomCenter,
                ),
                portalFollower: _buildOverlay(
                  constraints,
                  suggestions,
                  Colors.black.withValues(alpha: 0.7),
                ),
                visible:
                    overlay &&
                    suggestions.isNotEmpty &&
                    widget.controller.text != selectedTag,
                child: BooruSearchBar(
                  focus: widget.focusNode,
                  controller: widget.controller,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Symbols.search),
                  ),
                  trailing: ValueListenableBuilder(
                    valueListenable: widget.controller,
                    builder: (_, value, _) => value.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Symbols.clear),
                              onTap: () {
                                widget.controller.clear();
                                ref.read(selectedTagsProvider.notifier).state =
                                    '';
                                widget.focusNode.unfocus();
                              },
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  onSubmitted: (value) {
                    ref.read(selectedTagsProvider.notifier).state = value
                        .trim()
                        .replaceAll(RegExp(r'\s+'), ' ');
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOverlay(
    BoxConstraints constraints,
    List<String> suggestions,
    Color scrimColor,
  ) {
    return Column(
      children: [
        ColoredBox(
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
            height: suggestions.length * 44,
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              maxHeight: min(MediaQuery.sizeOf(context).height * 0.8, 300),
            ),
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final tag = suggestions[index];

                return _buildItem(ref, tag, context);
              },
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _overlay.value = false;
              widget.focusNode.unfocus();
            },
            child: Container(
              color: scrimColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(WidgetRef ref, String tag, BuildContext context) {
    final config = ref.watchConfigAuth;
    final color = ref
        .watch(bookmarkTagColorProvider((config, tag)))
        .valueOrNull;

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.transparent,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          // trim excess spaces, keep only the final space
          final currentTag = ref
              .read(selectedTagsProvider)
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ');

          final newTagString = currentTag.isEmpty
              ? '$tag '
              : '$currentTag $tag ';
          ref.read(selectedTagsProvider.notifier).state = newTagString;
          widget.controller.text = newTagString;
        },
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
                    valueListenable: widget.controller,
                    builder: (_, value, _) => AppHtml(
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
                          '<p>${tag.replaceAll(value.text, '<b>${value.text}</b>')}</p>',
                    ),
                  ),
                ),
                ref
                    .watch(tagCountProvider(tag))
                    .maybeWhen(
                      data: (count) => Text(
                        count.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.hintColor,
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
