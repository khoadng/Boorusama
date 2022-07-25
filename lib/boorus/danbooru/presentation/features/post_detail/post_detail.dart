// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'widgets/post_media_item.dart';
import 'widgets/widgets.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({
    Key? key,
    required this.post,
    this.minimal = false,
    required this.imagePath,
  }) : super(key: key);

  final Post post;
  final bool minimal;
  final ValueNotifier<String?> imagePath;

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  late final imagePath = widget.imagePath;
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenSize = screenWidthToDisplaySize(size.width);
    final postWidget = PostMediaItem(
      post: widget.post,
      onCached: (path) => imagePath.value = path,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.minimal
            ? Center(child: postWidget)
            : BlocBuilder<SettingsCubit, SettingsState>(
                buildWhen: (previous, current) =>
                    previous.settings.actionBarDisplayBehavior !=
                    current.settings.actionBarDisplayBehavior,
                builder: (context, state) {
                  return Stack(
                    children: [
                      CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(child: postWidget),
                          const SliverToBoxAdapter(child: PoolTiles()),
                          SliverToBoxAdapter(
                            child: InformationAndRecommended(
                              screenSize: screenSize,
                              post: widget.post,
                              actionBarDisplayBehavior:
                                  state.settings.actionBarDisplayBehavior,
                              imagePath: widget.imagePath,
                            ),
                          ),
                        ],
                      ),
                      if (state.settings.actionBarDisplayBehavior ==
                          ActionBarDisplayBehavior.staticAtBottom)
                        Positioned(
                          bottom: 6,
                          left: MediaQuery.of(context).size.width * 0.05,
                          child: FloatingGlassyCard(
                            child: ActionBar(
                              imagePath: widget.imagePath,
                              post: widget.post,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
