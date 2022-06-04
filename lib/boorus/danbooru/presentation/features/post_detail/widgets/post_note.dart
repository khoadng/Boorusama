// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_portal/flutter_portal.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note_coordinate.dart';

class PostNote extends HookWidget {
  const PostNote({
    Key? key,
    required this.coordinate,
    required this.content,
  }) : super(key: key);

  final NoteCoordinate coordinate;
  final String content;

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);
    Alignment portalAlignment;
    Alignment childAlignment;

    if (coordinate.x > MediaQuery.of(context).size.width / 2) {
      portalAlignment = Alignment.topRight;
      childAlignment = Alignment.bottomRight;
    } else {
      portalAlignment = Alignment.topLeft;
      childAlignment = Alignment.bottomLeft;
    }

    return PortalEntry(
      visible: visible.value,
      portal: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => visible.value = false,
      ),
      child: Container(
        margin: EdgeInsets.only(left: coordinate.x, top: coordinate.y),
        child: PortalEntry(
          portalAnchor: portalAlignment,
          childAnchor: childAlignment,
          visible: visible.value,
          portal: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.5),
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
            onTap: () => visible.value = true,
            child: Container(
              width: coordinate.width,
              height: coordinate.height,
              decoration: BoxDecoration(
                  color: Colors.white54,
                  border: Border.all(color: Colors.red, width: 1)),
            ),
          ),
        ),
      ),
    );
  }
}
