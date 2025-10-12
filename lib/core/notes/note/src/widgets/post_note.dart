// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../types/note.dart';
import '../types/note_coordinate.dart';
import '../types/note_display_mode.dart';
import '../types/note_style.dart';
import 'note_box.dart';

class PostNote extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return isMobilePlatform()
        ? PostNoteMobile(
            note: note,
            style: style,
            displayMode: displayMode,
          )
        : PostNoteDesktop(
            note: note,
            style: style,
            displayMode: displayMode,
          );
  }
}

class PostNoteDesktop extends StatefulWidget {
  const PostNoteDesktop({
    required this.note,
    super.key,
    this.style,
    this.displayMode,
  });

  final Note note;
  final NoteStyle? style;
  final NoteDisplayMode? displayMode;

  @override
  State<PostNoteDesktop> createState() => _PostNoteDesktopState();
}

class _PostNoteDesktopState extends State<PostNoteDesktop> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: _visible,
      portalFollower: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _visible = false),
      ),
      child: _NoteContainerDesktop(
        note: widget.note,
        style: widget.style,
        displayMode: widget.displayMode,
      ),
    );
  }
}

class _NoteContainerDesktop extends StatefulWidget {
  const _NoteContainerDesktop({
    required this.note,
    this.style,
    this.displayMode,
  });

  final Note note;
  final NoteStyle? style;
  final NoteDisplayMode? displayMode;

  @override
  State<_NoteContainerDesktop> createState() => _NoteContainerDesktopState();
}

class _NoteContainerDesktopState extends State<_NoteContainerDesktop> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final (coordinate, content) = (widget.note.coordinate, widget.note.content);

    return Container(
      margin: EdgeInsets.only(
        left: coordinate.x,
        top: coordinate.y,
      ),
      child: PortalTarget(
        anchor: switch (coordinate.calculateQuadrant(
          screenWidth,
          screenHeight,
        )) {
          NoteQuadrant.topLeft => const Aligned(
            follower: Alignment.topLeft,
            target: Alignment.bottomLeft,
          ),
          NoteQuadrant.topRight => const Aligned(
            follower: Alignment.topRight,
            target: Alignment.bottomRight,
          ),
          NoteQuadrant.bottomLeft => const Aligned(
            follower: Alignment.bottomLeft,
            target: Alignment.topLeft,
          ),
          NoteQuadrant.bottomRight => const Aligned(
            follower: Alignment.bottomRight,
            target: Alignment.topRight,
          ),
        },
        visible: _visible,
        portalFollower: Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(2),
          ),
          child: SingleChildScrollView(
            child: HtmlWidget(
              content,
            ),
          ),
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _visible = true),
          onExit: (_) => setState(() => _visible = false),
          child: NoteBox(
            note: widget.note,
            style: widget.style,
            displayMode: widget.displayMode,
          ),
        ),
      ),
    );
  }
}

class PostNoteMobile extends StatefulWidget {
  const PostNoteMobile({
    required this.note,
    super.key,
    this.style,
    this.displayMode,
  });

  final Note note;
  final NoteStyle? style;
  final NoteDisplayMode? displayMode;

  @override
  State<PostNoteMobile> createState() => _PostNoteMobileState();
}

class _PostNoteMobileState extends State<PostNoteMobile> {
  final _visible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _visible,
      builder: (context, visible, _) => PortalTarget(
        visible: visible,
        portalFollower: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _visible.value = false,
        ),
        child: _NoteContainerMobile(
          note: widget.note,
          visible: visible,
          onTap: () => _visible.value = true,
          style: widget.style,
          displayMode: widget.displayMode,
        ),
      ),
    );
  }
}

class _NoteContainerMobile extends StatelessWidget {
  const _NoteContainerMobile({
    required this.note,
    required this.visible,
    required this.onTap,
    this.style,
    this.displayMode,
  });

  final Note note;
  final bool visible;
  final VoidCallback onTap;
  final NoteStyle? style;
  final NoteDisplayMode? displayMode;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final (coordinate, content) = (note.coordinate, note.content);

    return Container(
      margin: EdgeInsets.only(
        left: coordinate.x,
        top: coordinate.y,
      ),
      child: PortalTarget(
        anchor: switch (coordinate.calculateQuadrant(
          screenWidth,
          screenHeight,
        )) {
          NoteQuadrant.topLeft => const Aligned(
            follower: Alignment.topLeft,
            target: Alignment.bottomLeft,
          ),
          NoteQuadrant.topRight => const Aligned(
            follower: Alignment.topRight,
            target: Alignment.bottomRight,
          ),
          NoteQuadrant.bottomLeft => const Aligned(
            follower: Alignment.bottomLeft,
            target: Alignment.topLeft,
          ),
          NoteQuadrant.bottomRight => const Aligned(
            follower: Alignment.bottomRight,
            target: Alignment.topRight,
          ),
        },
        visible: visible,
        portalFollower: Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(2),
          ),
          child: SingleChildScrollView(
            child: HtmlWidget(
              content,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: NoteBox(
            note: note,
            style: style,
            displayMode: displayMode,
          ),
        ),
      ),
    );
  }
}
