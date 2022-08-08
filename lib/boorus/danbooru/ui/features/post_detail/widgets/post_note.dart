// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_portal/flutter_portal.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostNote extends StatefulWidget {
  const PostNote({
    Key? key,
    required this.coordinate,
    required this.content,
  }) : super(key: key);

  final NoteCoordinate coordinate;
  final String content;

  @override
  State<PostNote> createState() => _PostNoteState();
}

class _PostNoteState extends State<PostNote> {
  final _visible = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _visible,
      builder: (context, visible, _) => PortalTarget(
        visible: visible,
        portalFollower: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _visible.value = false,
        ),
        child: NoteContainer(
          coordinate: widget.coordinate,
          visible: visible,
          onTap: () => _visible.value = true,
          content: widget.content,
        ),
      ),
    );
  }
}

class NoteContainer extends StatelessWidget {
  const NoteContainer({
    Key? key,
    required this.coordinate,
    required this.visible,
    required this.onTap,
    required this.content,
  }) : super(key: key);

  final NoteCoordinate coordinate;
  final bool visible;
  final String content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: coordinate.x,
        top: coordinate.y,
      ),
      child: PortalTarget(
        anchor: coordinate.x > MediaQuery.of(context).size.width / 2
            ? const Aligned(
                follower: Alignment.topRight,
                target: Alignment.bottomRight,
              )
            : const Aligned(
                follower: Alignment.topLeft,
                target: Alignment.bottomLeft,
              ),
        visible: visible,
        portalFollower: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          child: IntrinsicWidth(
            child: Material(
              child: Html(
                shrinkWrap: true,
                data: content,
              ),
            ),
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: coordinate.width,
            height: coordinate.height,
            decoration: BoxDecoration(
              color: Colors.white54,
              border: Border.all(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
