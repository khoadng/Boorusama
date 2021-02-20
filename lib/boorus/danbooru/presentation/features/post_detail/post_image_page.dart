// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/note_repository.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'widgets/post_note.dart';

final _notesProvider =
    FutureProvider.autoDispose.family<List<Note>, int>((ref, postId) async {
  // Cancel the HTTP request if the user leaves the detail page before
  // the request completes.
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final repo = ref.watch(noteProvider);
  final notes = await repo.getNotesFrom(postId, cancelToken: cancelToken);

  /// Cache the artist posts once it was successfully obtained.
  ref.maintainState = true;

  return notes;
});

class PostImagePage extends HookWidget {
  const PostImagePage({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment(-0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  List<Widget> buildNotes(BuildContext context, List<Note> notes, Post post) {
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
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final hideOverlay = useState(false);
    final notes = useProvider(_notesProvider(post.id));

    final image = CachedNetworkImage(
      fit: BoxFit.fitWidth,
      imageUrl: post.normalImageUri.toString(),
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
    );
    return Scaffold(
      body: Stack(
        children: [
          InkWell(
              onTap: () {
                hideOverlay.value = !hideOverlay.value;
              },
              child: image),
          if (!hideOverlay.value) ...[
            ShadowGradientOverlay(
                alignment: Alignment.topCenter,
                colors: <Color>[
                  const Color(0x8A000000),
                  Colors.black12.withOpacity(0.0)
                ]),
            _buildBackButton(context),
            ...notes.when(
              loading: () => [SizedBox.shrink()],
              data: (notes) => buildNotes(context, notes, post),
              error: (name, message) => [SizedBox.shrink()],
            ),
          ],
        ],
      ),
    );
  }
}

enum PostAction {
  download,
  slideShow,
}
