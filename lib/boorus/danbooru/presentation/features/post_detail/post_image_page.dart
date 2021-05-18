// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/note_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
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

  Widget _buildMoreButton(BuildContext context) {
    return Align(
      alignment: Alignment(0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PopupMenuButton<PostAction>(
          onSelected: (value) async {
            switch (value) {
              case PostAction.download:
                context.read(downloadServiceProvider).download(post);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
            PopupMenuItem<PostAction>(
              value: PostAction.download,
              child: ListTile(
                leading: const Icon(Icons.download_rounded),
                title: Text("Download"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildNotes(BuildContext context, List<Note> notes, Post post) {
    final widgets = <Widget>[];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            _buildMoreButton(context),
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
