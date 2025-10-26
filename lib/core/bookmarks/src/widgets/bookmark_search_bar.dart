// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../foundation/html.dart';
import '../../../../foundation/platform.dart';
import '../../../configs/config/providers.dart';
import '../../../posts/listing/providers.dart';
import '../../../search/queries/types.dart';
import '../../../search/search/widgets.dart';
import '../../../themes/theme/types.dart';
import '../providers/suggestion_provider.dart';

class BookmarkSearchBar extends ConsumerStatefulWidget {
  const BookmarkSearchBar({
    required this.controller,
    required this.postController,
    super.key,
  });

  final TextEditingController controller;
  final PostGridController postController;

  @override
  ConsumerState<BookmarkSearchBar> createState() => _BookmarkSearchBarState();
}

class _BookmarkSearchBarState extends ConsumerState<BookmarkSearchBar> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: AnchorPopover(
              triggerMode: AnchorTriggerMode.focus(
                focusNode: _focusNode,
              ),
              spacing: 4,
              arrowShape: const NoArrow(),
              backdropBuilder: (context) => isMobilePlatform()
                  ? Container(
                      color: Colors.black54,
                    )
                  : const SizedBox.shrink(),
              placement: Placement.bottom,
              overlayBuilder: (context) => Container(
                constraints: BoxConstraints(
                  maxWidth:
                      AnchorData.of(context).geometry.childBounds?.width ??
                      double.infinity,
                  maxHeight: min(
                    300,
                    MediaQuery.sizeOf(context).height * 0.4,
                  ),
                ),
                child: _Overlay(
                  controller: widget.controller,
                  onTap: (tag) {
                    widget.controller.text = replaceOrAppendTag(
                      widget.controller.text,
                      tag.tag,
                    );
                    _search();
                  },
                ),
              ),

              child: ValueListenableBuilder(
                valueListenable: widget.controller,
                builder: (context, controller, child) =>
                    _buildSearchBar(controller),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _search() {
    widget.postController.refresh();
  }

  Widget _buildSearchBar(TextEditingValue controller) {
    return BooruSearchBar(
      focus: _focusNode,
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
    required this.onTap,
  });

  final TextEditingController controller;
  final ValueChanged<TagWithColor> onTap;

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
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: switch (ref.watch(tagSuggestionsProvider)) {
        AsyncData(:final value) when value.suggestions.isNotEmpty =>
          ListView.builder(
            shrinkWrap: true,
            itemCount: value.suggestions.length,
            itemBuilder: (context, index) {
              final tag = value.suggestions[index];

              return _SuggestionItem(
                tagWithColor: tag,
                controller: widget.controller,
                onTap: () {
                  widget.onTap(tag);
                },
              );
            },
          ),
        _ => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            context.t.generic.no_content,
            style: TextStyle(
              color: colorScheme.hintColor,
            ),
          ),
        ),
      },
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
