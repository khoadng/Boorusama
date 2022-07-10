// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'widgets/post_note.dart';

class PostImagePage extends StatefulWidget {
  const PostImagePage({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<PostImagePage> createState() => _PostImagePageState();
}

class _PostImagePageState extends State<PostImagePage>
    with SingleTickerProviderStateMixin {
  final hideOverlay = ValueNotifier(true);
  final fullsize = ValueNotifier(false);
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  late final AnimationController _animationController;
  late Animation<Matrix4> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => _transformationController.value = _animation.value);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        onTap: () => hideOverlay.value = !hideOverlay.value,
        child: InteractiveViewer(
          minScale: 0.6,
          maxScale: 5,
          transformationController: _transformationController,
          child: BlocBuilder<NoteBloc, AsyncLoadState<List<Note>>>(
            builder: (context, state) => ValueListenableBuilder<bool>(
              valueListenable: hideOverlay,
              builder: (context, hide, child) => Stack(
                children: [
                  child!,
                  if (!hide) ...[
                    ShadowGradientOverlay(
                        alignment: Alignment.topCenter,
                        colors: <Color>[
                          const Color(0x8A000000),
                          Colors.black12.withOpacity(0)
                        ]),
                    _buildBackButton(),
                    ValueListenableBuilder<bool>(
                      valueListenable: fullsize,
                      builder: (context, useFullsize, child) =>
                          _buildMoreButton(useFullsize, widget.post.hasLarge),
                    ),
                    if (state.status == LoadStatus.success)
                      ...buildNotes(state.data!, widget.post)
                    else
                      const SizedBox.shrink()
                  ],
                ],
              ),
              child: Align(
                child: ValueListenableBuilder<bool>(
                  valueListenable: fullsize,
                  builder: (context, useFullsize, _) {
                    return _buildImage(
                      useFullsize
                          ? widget.post.fullImageUrl
                          : widget.post.normalImageUrl,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    Matrix4 endMatrix;
    final position = _doubleTapDetails!.localPosition;

    if (_transformationController.value != Matrix4.identity()) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(
      CurveTween(curve: Curves.easeInOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      fit: BoxFit.fitWidth,
      imageUrl: imageUrl,
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  Widget _buildBackButton() {
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

  Widget _buildMoreButton(bool useFullsize, bool hasLarge) {
    return Align(
      alignment: const Alignment(0.9, -0.96),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DownloadProviderWidget(
          builder: (context, download) => PopupMenuButton<PostAction>(
            onSelected: (value) async {
              switch (value) {
                case PostAction.download:
                  download(widget.post);
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
              if (hasLarge)
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

  List<Widget> buildNotes(
    List<Note> notes,
    Post post,
  ) {
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
