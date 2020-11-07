import 'package:boorusama/application/posts/post_translate_note/bloc/post_translate_note_bloc.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:super_tooltip/super_tooltip.dart';

class PostImage extends StatefulWidget {
  PostImage(
      {@required this.post,
      this.onLongPressed,
      this.onNoteVisibleChanged,
      this.postHeroTag,
      @required this.controller});

  final ValueChanged<bool> onNoteVisibleChanged;
  final Function onLongPressed;
  final Post post;
  final PostImageController controller;
  final String postHeroTag;

  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  bool notesVisible = false;
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
    return Hero(
      tag: widget.postHeroTag,
      child: BlocListener<PostTranslateNoteBloc, PostTranslateNoteState>(
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
        child: notesVisible
            ? buildNotesAndImage()
            : buildCachedNetworkImage(context),
      ),
    );
  }

  Widget buildCachedNetworkImage(BuildContext context) {
    return GestureDetector(
      onLongPress: () => widget.onLongPressed(),
      child: _Image(imageUrl: widget.post.normalImageUri.toString()),
    );
  }

  Widget buildNotesAndImage() {
    final widgets = List<Widget>();

    final screenWidth = MediaQuery.of(context).size.width;
    //TODO: remove hardcode, hacky solution
    final screenHeight = MediaQuery.of(context).size.height -
        60.0 -
        80; // minus toolbar height (60) and some offset (70) ;
    final screenAspectRatio = screenWidth / screenHeight;

    widgets.add(_Image(imageUrl: widget.post.normalImageUri.toString()));

    for (var note in notes) {
      final coordinate = note.coordinate.calibrate(
          screenHeight,
          screenWidth,
          screenAspectRatio,
          widget.post.height,
          widget.post.width,
          widget.post.aspectRatio);

      var tooltip = SuperTooltip(
        backgroundColor: ThemeData.dark().cardColor,
        arrowTipDistance: 0,
        arrowBaseWidth: 0,
        arrowLength: 0,
        popupDirection: TooltipDirection.left,
        content: Material(
          child: Html(data: note.content),
          color: ThemeData.dark().cardColor,
        ),
      );

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
      notesVisible = true;
    });

    widget.onNoteVisibleChanged(notesVisible);
  }

  void hideTranslationNotes() {
    setState(() {
      notesVisible = false;
    });

    widget.onNoteVisibleChanged(notesVisible);
  }
}

class _Image extends StatelessWidget {
  const _Image({
    Key key,
    @required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: BoxDecoration(
            color: ThemeData.dark().appBarTheme.color,
          ),
        );
      },
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class PostImageController {
  _PostImageState postImageState;

  PostImageController();

  bool get notesVisible => postImageState.notesVisible;

  void showTranslationNotes() {
    postImageState.showTranslationNotes();
  }

  void hideTranslationNotes() {
    postImageState.hideTranslationNotes();
  }

  void toggleTranslationNotes() {
    postImageState.notesVisible
        ? postImageState.hideTranslationNotes()
        : postImageState.showTranslationNotes();
  }

  void dispose() {
    postImageState = null;
  }
}
