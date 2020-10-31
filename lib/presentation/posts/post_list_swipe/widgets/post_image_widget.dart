import 'package:boorusama/application/posts/post_translate_note/bloc/post_translate_note_bloc.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:super_tooltip/super_tooltip.dart';

class PostImage extends StatefulWidget {
  PostImage(
      {@required this.post,
      this.onNoteVisibleChanged,
      @required this.controller});

  final ValueChanged<bool> onNoteVisibleChanged;
  final Post post;
  final PostImageController controller;

  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  bool _notesVisible = false;
  List<Note> notes;
  PostTranslateNoteBloc _postTranslateNoteBloc;

  @override
  void initState() {
    super.initState();
    _postTranslateNoteBloc = BlocProvider.of<PostTranslateNoteBloc>(context);
    widget.controller.postImageState = this;

    notes = List<Note>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostTranslateNoteBloc, PostTranslateNoteState>(
      listener: (context, state) {
        if (state is PostTranslateNoteFetched) {
          setState(() {
            notes = state.notes;
          });
        } else if (state is PostTranslateNoteInProgress) {
          Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(milliseconds: 1000),
              content: Text("Fetching translation notes, plese hold on...")));
        } else {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("Oopsie something went wrong")));
        }
      },
      child: _notesVisible
          ? buildNotesAndImage()
          : buildCachedNetworkImage(context),
    );
  }

  Widget buildCachedNetworkImage(BuildContext context) {
    return OptimizedCacheImage(
      imageUrl: widget.post.normalImageUri.toString(),
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return PhotoView(imageProvider: imageProvider);
      },
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Widget buildNotesAndImage() {
    final widgets = List<Widget>();

    final screenWidth = MediaQuery.of(context).size.width;
    //TODO: remove hardcode, hacky solution
    final screenHeight = MediaQuery.of(context).size.height -
        40.0 -
        20; // minus toolbar height (40) and some offset (20) ;
    final screenAspectRatio = screenWidth / screenHeight;

    widgets.add(OptimizedCacheImage(
      imageUrl: widget.post.normalImageUri.toString(),
      imageBuilder: (context, imageProvider) =>
          PhotoView(imageProvider: imageProvider),
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ));

    for (var note in notes) {
      final coordinate = note.coordinate.calibrate(
          screenHeight,
          screenWidth,
          screenAspectRatio,
          widget.post.height,
          widget.post.width,
          widget.post.aspectRatio);

      var tooltip = SuperTooltip(
          arrowTipDistance: 0,
          arrowBaseWidth: 0,
          arrowLength: 0,
          popupDirection: TooltipDirection.left,
          content: Material(child: Html(data: note.content)));

      widgets.add(
        GestureDetector(
          onTap: () => tooltip.show(context),
          child: Container(
            margin: EdgeInsets.only(left: coordinate.x, top: coordinate.y),
            width: coordinate.width,
            height: coordinate.height,
            decoration: BoxDecoration(
                color: Colors.white54,
                border: Border.all(color: Colors.red, width: 1)),
          ),
        ),
      );
    }

    return Stack(children: widgets);
  }

  void showTranslationNotes() {
    if (notes.isEmpty) {
      _postTranslateNoteBloc.add(GetTranslatedNotes(postId: widget.post.id));
    }

    setState(() {
      _notesVisible = true;
    });

    widget.onNoteVisibleChanged(_notesVisible);
  }

  void hideTranslationNotes() {
    setState(() {
      _notesVisible = false;
    });

    widget.onNoteVisibleChanged(_notesVisible);
  }
}

class PostImageController {
  _PostImageState postImageState;

  PostImageController();

  void showTranslationNotes() {
    postImageState.showTranslationNotes();
  }

  void hideTranslationNotes() {
    postImageState.hideTranslationNotes();
  }

  void toggleTranslationNotes() {
    postImageState._notesVisible
        ? postImageState.hideTranslationNotes()
        : postImageState.showTranslationNotes();
  }

  void dispose() {
    postImageState = null;
  }
}
