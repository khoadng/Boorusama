// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/widgets/post_note.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';

class PoolReaderPage extends StatefulWidget {
  const PoolReaderPage({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<PoolReaderPage> createState() => _PoolReaderPageState();
}

class _PoolReaderPageState extends State<PoolReaderPage> {
  @override
  void initState() {
    super.initState();
    context.read<NoteCubit>().getNote(widget.post.id);
  }

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
    return Scaffold(
      body: InteractiveViewer(
        child: BlocBuilder<NoteCubit, AsyncLoadState<List<Note>>>(
          builder: (context, state) => Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  imageUrl: widget.post.normalImageUri.toString(),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                      value: progress.progress,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              ...[
                ShadowGradientOverlay(
                    alignment: Alignment.topCenter,
                    colors: <Color>[
                      const Color(0x8A000000),
                      Colors.black12.withOpacity(0.0)
                    ]),
                _buildBackButton(context),
                // _buildMoreButton(context),
                if (state.status == LoadStatus.success)
                  ...buildNotes(context, state.data!, widget.post)
                else
                  SizedBox.shrink()
              ],
            ],
          ),
        ),
      ),
    );
  }
}
