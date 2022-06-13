// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'widgets/post_note.dart';

class PostImagePage extends HookWidget {
  const PostImagePage({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return Align(
      alignment: const Alignment(0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: PopupMenuButton<PostAction>(
          onSelected: (value) async {
            switch (value) {
              case PostAction.download:
                RepositoryProvider.of<IDownloadService>(context).download(post);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<PostAction>>[
            const PopupMenuItem<PostAction>(
              value: PostAction.download,
              child: ListTile(
                leading: Icon(Icons.download_rounded),
                title: Text('Download'),
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

    for (final note in notes) {
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

    final image = CachedNetworkImage(
      fit: BoxFit.fitWidth,
      imageUrl: post.normalImageUrl,
      imageBuilder: (context, imageProvider) {
        precacheImage(imageProvider, context);
        return PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
        );
      },
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return Scaffold(
      body: BlocBuilder<NoteBloc, AsyncLoadState<List<Note>>>(
        builder: (context, state) => Stack(
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
                    Colors.black12.withOpacity(0)
                  ]),
              _buildBackButton(context),
              _buildMoreButton(context),
              if (state.status == LoadStatus.success)
                ...buildNotes(context, state.data!, post)
              else
                const SizedBox.shrink()
            ],
          ],
        ),
      ),
    );
  }
}

enum PostAction {
  download,
  slideShow,
}
