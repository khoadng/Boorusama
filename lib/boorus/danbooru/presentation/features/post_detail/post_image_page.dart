// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'widgets/post_note.dart';

class PostImagePage extends StatelessWidget {
  PostImagePage({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;
  final hideOverlay = ValueNotifier(false);
  final fullsize = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NoteBloc, AsyncLoadState<List<Note>>>(
        builder: (context, state) => Stack(
          children: [
            InkWell(
              onTap: () => hideOverlay.value = !hideOverlay.value,
              child: ValueListenableBuilder<bool>(
                valueListenable: fullsize,
                builder: (context, useFullsize, _) {
                  return _buildImage(
                    useFullsize ? post.fullImageUrl : post.normalImageUrl,
                  );
                },
              ),
            ),
            if (!hideOverlay.value) ...[
              ShadowGradientOverlay(
                  alignment: Alignment.topCenter,
                  colors: <Color>[
                    const Color(0x8A000000),
                    Colors.black12.withOpacity(0)
                  ]),
              _buildBackButton(context),
              ValueListenableBuilder<bool>(
                valueListenable: fullsize,
                builder: (context, useFullsize, child) => _buildMoreButton(
                  context,
                  useFullsize,
                ),
              ),
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

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      fit: BoxFit.fitWidth,
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
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
  }

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

  Widget _buildMoreButton(
    BuildContext context,
    bool useFullsize,
  ) {
    return Align(
      alignment: const Alignment(0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DownloadProviderWidget(
          builder: (context, download) => PopupMenuButton<PostAction>(
            onSelected: (value) async {
              switch (value) {
                case PostAction.download:
                  download(post);
                  break;
                case PostAction.viewFullsize:
                  fullsize.value = true;
                  break;
                case PostAction.viewNormalsize:
                  fullsize.value = false;
                  break;
                default:
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<PostAction>(
                value: PostAction.download,
                child: ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Download'),
                ),
              ),
              if (useFullsize)
                const PopupMenuItem<PostAction>(
                  value: PostAction.viewNormalsize,
                  child: ListTile(
                    leading: Icon(Icons.fullscreen_exit),
                    title: Text('View normal size image'),
                  ),
                )
              else
                const PopupMenuItem<PostAction>(
                  value: PostAction.viewFullsize,
                  child: ListTile(
                    leading: Icon(Icons.fullscreen),
                    title: Text('View full size image'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNotes(BuildContext context, List<Note> notes, Post post) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenAspectRatio = screenWidth / screenHeight;
    return notes
        .map(
          (note) => PostNote(
            coordinate: note.coordinate.calibrate(
              screenHeight,
              screenWidth,
              screenAspectRatio,
              post.height,
              post.width,
              post.aspectRatio,
            ),
            content: note.content,
          ),
        )
        .toList();
  }
}

enum PostAction {
  download,
  viewFullsize,
  viewNormalsize,
  slideShow,
}
