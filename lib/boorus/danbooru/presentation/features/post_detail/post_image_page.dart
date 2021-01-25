// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post_detail/notes/notes_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'widgets/post_note.dart';

final notesStateNotifierProvider =
    StateNotifierProvider<NotesStateNotifier>((ref) => NotesStateNotifier(ref));

class PostImagePage extends StatefulWidget {
  const PostImagePage({
    Key key,
    @required this.post,
    @required this.heroTag,
  }) : super(key: key);

  final Post post;
  final String heroTag;

  @override
  _PostImagePageState createState() => _PostImagePageState();
}

class _PostImagePageState extends State<PostImagePage> {
  bool _hideOverlay = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () =>
            context.read(notesStateNotifierProvider).getNotes(widget.post.id));
  }

  @override
  Widget build(BuildContext context) {
    final image = Hero(
        tag: widget.heroTag,
        child: CachedNetworkImage(
          fit: BoxFit.fitWidth,
          imageUrl: widget.post.normalImageUri.toString(),
          imageBuilder: (context, imageProvider) {
            precacheImage(imageProvider, context);
            return PhotoView(
              imageProvider: imageProvider,
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.color,
              ),
            );
          },
          progressIndicatorBuilder: (context, url, progress) => Center(
            child: CircularProgressIndicator(
              value: progress.progress,
            ),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ));
    return SafeArea(
      child: Scaffold(
        body: Consumer(
          builder: (context, watch, child) {
            final state = watch(notesStateNotifierProvider.state);
            final imageAndOverlay = Stack(
              children: [
                image,
                if (!_hideOverlay) _buildTopShadowGradient(),
                if (!_hideOverlay) _buildBackButton(context),
                if (!_hideOverlay) _buildMoreVertButton(),
              ],
            );
            return state.when(
              initial: () => imageAndOverlay,
              loading: () => imageAndOverlay,
              fetched: (notes) => Stack(
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          _hideOverlay = !_hideOverlay;
                        });

                        if (_hideOverlay) {
                          SystemChrome.setEnabledSystemUIOverlays([]);
                        } else {
                          SystemChrome.setEnabledSystemUIOverlays(
                              SystemUiOverlay.values);
                        }
                      },
                      child: image),
                  if (!_hideOverlay) _buildTopShadowGradient(),
                  if (!_hideOverlay) ...buildNotes(notes, widget.post),
                  if (!_hideOverlay) _buildBackButton(context),
                  if (!_hideOverlay) _buildMoreVertButton(),
                ],
              ),
              error: (name, message) => imageAndOverlay,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopShadowGradient() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            end: const Alignment(0.0, 0.4),
            begin: const Alignment(0.0, -1),
            colors: <Color>[
              const Color(0x8A000000),
              Colors.black12.withOpacity(0.0)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildMoreVertButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton<PostAction>(
          onSelected: (value) {
            switch (value) {
              case PostAction.download:
                // context
                //     .read(postDownloadStateNotifierProvider)
                //     .download(
                //         post.downloadLink, post.descriptiveName);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
            PopupMenuItem<PostAction>(
              value: PostAction.download,
              child: ListTile(
                // leading: const Icon(Icons.download_rounded),
                title: Text("Placeholder"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildNotes(List<Note> notes, Post post) {
    final widgets = List<Widget>();

    final screenWidth = MediaQuery.of(context).size.width;
    //TODO: Can't get status bar height inside Scaffold
    final screenHeight =
        MediaQuery.of(context).size.height /* - kToolbarHeight */ - 24;
    /*60*/ // minus toolbar height, status bar height and custom value for the bottom sheet;
    final screenAspectRatio = screenWidth / screenHeight;

    for (var note in notes) {
      final coordinate = note.coordinate.calibrate(screenHeight, screenWidth,
          screenAspectRatio, post.height, post.width, post.aspectRatio);

      widgets.add(
        PostNote(
          coordinate: coordinate,
          content: note.content,
          targetContext: context,
        ),
      );
    }

    return widgets;
  }
}

enum PostAction { download }
