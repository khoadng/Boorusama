// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_popover/flutter_popover.dart';
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
  });

  final NoteStyle? style;
  final NoteDisplayMode? displayMode;
  final Note note;

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

    return Container(
      margin: coordinate.getMargin(),
      child: Popover(
        triggerMode: isMobile
            ? PopoverTriggerMode.tap
            : PopoverTriggerMode.hover,
        showDelay: isMobile ? null : Duration.zero,
        overlayChildHeight: _maxOverlayHeight,
        overlayChildWidth: _maxOverlayWidth,
        barrierColor: isMobile ? Colors.black38 : null,
        consumeOutsideTap: isMobile ? false : null,
        preferredDirection: AxisDirection.down,
        constrainAxis: Axis.vertical,
        crossAxisAlignment: PopoverCrossAxisAlignment.start,
        transitionDuration: Duration.zero,
        transitionBuilder: (context, animation, child) => child!,
        overlayChildBuilder: (context) => Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            maxWidth: _maxOverlayWidth,
            maxHeight: _maxOverlayHeight,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(2),
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
