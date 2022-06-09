// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_detail_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_read_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/pool/pool_reader_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';

class PoolDetailPage extends StatefulWidget {
  const PoolDetailPage({
    Key? key,
    required this.poolName,
    required this.poolDescription,
    required this.poolUpdatedTime,
    required this.postIds,
  }) : super(key: key);

  final String poolName;
  final String poolDescription;
  final String poolUpdatedTime;
  final List<int> postIds;

  @override
  State<PoolDetailPage> createState() => _PoolDetailPageState();
}

class _PoolDetailPageState extends State<PoolDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PoolDetailCubit>().getPoolDetail(widget.postIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(widget.poolName),
            ),
            SliverToBoxAdapter(
              child: Text(widget.poolDescription),
            ),
            SliverToBoxAdapter(
              child: Text("Last updated: ${widget.poolUpdatedTime}"),
            ),
            BlocBuilder<PoolDetailCubit, AsyncLoadState<List<Post>>>(
              builder: (context, state) {
                if (state.status == LoadStatus.success) {
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.65,
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final post = state.data![index];
                        final items = <Widget>[];

                        if (post.isAnimated) {
                          items.add(
                            const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white70,
                            ),
                          );
                        }

                        if (post.isTranslated) {
                          items.add(
                            const Icon(
                              Icons.g_translate_outlined,
                              color: Colors.white70,
                            ),
                          );
                        }

                        if (post.hasComment) {
                          items.add(
                            const Icon(
                              Icons.comment,
                              color: Colors.white70,
                            ),
                          );
                        }

                        return OpenContainer(
                          closedBuilder: (context, action) => Stack(
                            children: <Widget>[
                              PostImage(
                                imageUrl: post.isAnimated
                                    ? post.previewImageUri.toString()
                                    : post.normalImageUri.toString(),
                                placeholderUrl: post.previewImageUri.toString(),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: ShadowGradientOverlay(
                                  alignment: Alignment.topCenter,
                                  colors: <Color>[
                                    const Color(0x2F000000),
                                    Colors.black12.withOpacity(0.0)
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: IgnorePointer(
                                  child: Column(
                                    children: items,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          openColor: Colors.transparent,
                          closedColor: Colors.transparent,
                          openBuilder: (_, action) =>
                              MultiBlocProvider(providers: [
                            BlocProvider.value(
                                value: BlocProvider.of<NoteCubit>(context)),
                            BlocProvider(
                              create: (_) => PoolReadCubit(
                                initialState: PoolReadState(
                                  imageUrl: post.normalImageUri.toString(),
                                  currentIdx: index,
                                  post: post,
                                ),
                                posts: state.data!,
                              ),
                            )
                          ], child: const PoolReaderPage()),
                        );
                      },
                      childCount: state.data!.length,
                    ),
                  );
                } else if (state.status == LoadStatus.failure) {
                  return const SizedBox.shrink();
                } else {
                  return const SliverPostGridPlaceHolder();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
