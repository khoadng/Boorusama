// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_read_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/widgets/post_note.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';

class PoolReaderPage extends StatelessWidget {
  const PoolReaderPage({
    Key? key,
  }) : super(key: key);

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
    return Scaffold(
      floatingActionButton: ButtonBar(
        children: [
          IconButton(
              onPressed: () => context.read<PoolReadCubit>().previous(),
              icon: const Icon(Icons.arrow_left)),
          IconButton(
              onPressed: () => context.read<PoolReadCubit>().next(),
              icon: const Icon(Icons.arrow_right)),
        ],
      ),
      body: BlocConsumer<PoolReadCubit, PoolReadState>(
        listenWhen: (previous, current) => previous.post.id != current.post.id,
        listener: (context, state) =>
            context.read<NoteBloc>().add(NoteRequested(postId: state.post.id)),
        buildWhen: (previous, current) => previous.imageUrl != current.imageUrl,
        builder: (context, prs) {
          return InteractiveViewer(
            child: BlocBuilder<NoteBloc, AsyncLoadState<List<Note>>>(
              builder: (context, state) => Stack(
                children: [
                  Align(
                    child: CachedNetworkImage(
                      imageUrl: prs.imageUrl,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  ...[
                    ShadowGradientOverlay(
                        alignment: Alignment.topCenter,
                        colors: <Color>[
                          const Color(0x8A000000),
                          Colors.black12.withOpacity(0)
                        ]),
                    _buildBackButton(context),
                    // _buildMoreButton(context),
                    if (state.status == LoadStatus.success)
                      ...buildNotes(context, state.data!, prs.post)
                    else
                      const SizedBox.shrink()
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
