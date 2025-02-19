// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

// Project imports:
import '../../foundation/display.dart';
import '../../foundation/html.dart';
import '../notes.dart';

class NoteStyle extends Equatable {
  const NoteStyle({
    this.borderColor,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Color? borderColor;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  List<Object?> get props => [
        borderColor,
        backgroundColor,
        foregroundColor,
      ];
}

class PostNote extends StatelessWidget {
  const PostNote({
    required this.coordinate,
    required this.content,
    super.key,
    this.style,
  });

  final NoteCoordinate coordinate;
  final String content;
  final NoteStyle? style;

  @override
  Widget build(BuildContext context) {
    return kPreferredLayout.isMobile
        ? PostNoteMobile(
            coordinate: coordinate,
            content: content,
            style: style,
          )
        : PostNoteDesktop(
            coordinate: coordinate,
            content: content,
            style: style,
          );
  }
}

class PostNoteDesktop extends StatefulWidget {
  const PostNoteDesktop({
    required this.coordinate,
    required this.content,
    super.key,
    this.style,
  });

  final NoteCoordinate coordinate;
  final String content;
  final NoteStyle? style;

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
        coordinate: widget.coordinate,
        content: widget.content,
        style: widget.style,
      ),
    );
  }
}

class _NoteContainerDesktop extends StatefulWidget {
  const _NoteContainerDesktop({
    required this.coordinate,
    required this.content,
    this.style,
  });

  final NoteCoordinate coordinate;
  final String content;
  final NoteStyle? style;

  @override
  State<_NoteContainerDesktop> createState() => _NoteContainerDesktopState();
}

class _NoteContainerDesktopState extends State<_NoteContainerDesktop> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: widget.coordinate.x,
        top: widget.coordinate.y,
      ),
      child: PortalTarget(
        anchor: widget.coordinate.x > MediaQuery.sizeOf(context).width / 2
            ? const Aligned(
                follower: Alignment.topRight,
                target: Alignment.bottomRight,
              )
            : const Aligned(
                follower: Alignment.topLeft,
                target: Alignment.bottomLeft,
              ),
        visible: _visible,
        portalFollower: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.5,
          ),
          child: Material(
            child: SingleChildScrollView(
              child: AppHtml(
                data: widget.content,
              ),
            ),
          ),
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => _visible = true),
          onExit: (_) => setState(() => _visible = false),
          child: Container(
            width: widget.coordinate.width,
            height: widget.coordinate.height,
            decoration: BoxDecoration(
              color: widget.style?.backgroundColor ?? Colors.white54,
              border: Border.fromBorderSide(
                BorderSide(
                  color: widget.style?.borderColor ?? Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostNoteMobile extends StatefulWidget {
  const PostNoteMobile({
    required this.coordinate,
    required this.content,
    super.key,
    this.style,
  });

  final NoteCoordinate coordinate;
  final String content;
  final NoteStyle? style;

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
          coordinate: widget.coordinate,
          visible: visible,
          onTap: () => _visible.value = true,
          content: widget.content,
          style: widget.style,
        ),
      ),
    );
  }
}

class _NoteContainerMobile extends StatelessWidget {
  const _NoteContainerMobile({
    required this.coordinate,
    required this.visible,
    required this.onTap,
    required this.content,
    this.style,
  });

  final NoteCoordinate coordinate;
  final bool visible;
  final String content;
  final VoidCallback onTap;
  final NoteStyle? style;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      margin: EdgeInsets.only(
        left: coordinate.x,
        top: coordinate.y,
      ),
      child: PortalTarget(
        anchor: switch (
            coordinate.calculateQuadrant(screenWidth, screenHeight)) {
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
          child: Container(
            width: coordinate.width,
            height: coordinate.height,
            decoration: BoxDecoration(
              color: style?.backgroundColor ?? Colors.white54,
              border: Border.fromBorderSide(
                BorderSide(
                  color: style?.borderColor ?? Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
