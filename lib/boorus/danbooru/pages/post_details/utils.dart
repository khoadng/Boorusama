// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/widgets/post_note.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';

List<Widget> noteOverlayBuilderDelegate(BoxConstraints constraints,
        DanbooruPost post, NotesControllerState noteState) =>
    [
      if (noteState.enableNotes)
        ...noteState.notes
            .map((e) => e.adjustNoteCoordFor(
                  post,
                  widthConstraint: constraints.maxWidth,
                  heightConstraint: constraints.maxHeight,
                ))
            .map((e) => PostNote(
                  coordinate: e.coordinate,
                  content: e.content,
                )),
    ];
