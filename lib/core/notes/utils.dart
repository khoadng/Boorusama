// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';

List<Widget> noteOverlayBuilderDelegate(BoxConstraints constraints, Post post,
        NotesControllerState noteState) =>
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
