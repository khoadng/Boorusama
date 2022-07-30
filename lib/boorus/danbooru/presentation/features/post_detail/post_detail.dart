// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/parent_child_post_page.dart';
import 'models/parent_child_data.dart';
import 'widgets/widgets.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({
    Key? key,
    required this.post,
    this.minimal = false,
    required this.imagePath,
    required this.childBuilder,
  }) : super(key: key);

  final Post post;
  final bool minimal;
  final ValueNotifier<String?> imagePath;
  final Widget Function(
    BuildContext context,
    Post post,
  ) childBuilder;

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: widget.minimal
            ? Center(child: widget.childBuilder(context, widget.post))
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
                          SliverToBoxAdapter(
                            child: widget.childBuilder(
                              context,
                              widget.post,
                            ),
                          ),
                          const SliverToBoxAdapter(child: PoolTiles()),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InformationSection(post: widget.post),
                                if (state.settings.actionBarDisplayBehavior ==
                                    ActionBarDisplayBehavior.scrolling)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ActionBar(
                                      imagePath: imagePath,
                                      post: widget.post,
                                    ),
                                  ),
                                if (widget.post.hasParentOrChildren)
                                  ParentChildTile(
                                    data: getParentChildData(widget.post),
                                    onTap: (data) => showBarModalBottomSheet(
                                      context: context,
                                      builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) => PostBloc(
                                              postRepository: context
                                                  .read<IPostRepository>(),
                                              blacklistedTagsRepository:
                                                  context.read<
                                                      BlacklistedTagsRepository>(),
                                            )..add(PostRefreshed(
                                                tag: data
                                                    .tagQueryForDataFetching)),
                                          )
                                        ],
                                        child: ParentChildPostPage(
                                            parentPostId: data.parentId),
                                      ),
                                    ),
                                  ),
                                if (!widget.post.hasParentOrChildren)
                                  const Divider(height: 8, thickness: 1),
                                RecommendArtistList(post: widget.post),
                                RecommendCharacterList(post: widget.post),
                              ],
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
