// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../types/note.dart';
import '../types/note_display_mode.dart';
import '../types/note_style.dart';
import 'note_box.dart';

const _maxOverlayWidth = 200.0;
const _maxOverlayHeight = 300.0;

class PostNote extends StatefulWidget {
  const PostNote({
    required this.note,
    super.key,
    this.style,
    this.displayMode,
    this.onShow,
    this.onHide,
  });

  final NoteStyle? style;
  final NoteDisplayMode? displayMode;
  final Note note;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  @override
  State<PostNote> createState() => _PostNoteState();
}

class _PostNoteState extends State<PostNote> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (coordinate, content) = (widget.note.coordinate, widget.note.content);
    final isMobile = isMobilePlatform();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: coordinate.getMargin(),
      child: Anchor(
        triggerMode: isMobile
            ? const AnchorTriggerMode.tap(
                consumeOutsideTap: false,
              )
            : const AnchorTriggerMode.hover(
                waitDuration: Duration.zero,
              ),
        onShow: widget.onShow,
        onHide: widget.onHide,
        placement: isMobile ? Placement.bottomStart : Placement.bottom,
        transitionDuration: Duration.zero,
        transitionBuilder: (context, animation, child) => child!,
        viewPadding: const EdgeInsets.all(4),
        overlayBuilder: (context) => Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            maxWidth: _maxOverlayWidth,
            maxHeight: _maxOverlayHeight,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: HtmlWidget(
                content,
              ),
            ),
          ),
        ),
        child: NoteBox(
          note: widget.note,
          style: widget.style,
          displayMode: widget.displayMode,
        ),
      ),
    );
  }
}
