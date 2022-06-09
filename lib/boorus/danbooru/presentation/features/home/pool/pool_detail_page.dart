// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/note/note_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_description_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_detail_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_read_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/home/pool/pool_reader_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/post_image.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid_placeholder.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/utils.dart';

class PoolDetailPage extends StatefulWidget {
  const PoolDetailPage({
    Key? key,
    required this.pool,
  }) : super(key: key);

  final Pool pool;

  @override
  State<PoolDetailPage> createState() => _PoolDetailPageState();
}

class _PoolDetailPageState extends State<PoolDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PoolDetailCubit>().getPoolDetail(widget.pool.postIds);
    context.read<PoolDescriptionCubit>().getDescription(widget.pool.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ListTile(
                title: Text(
                  widget.pool.name.value.removeUnderscoreWithSpace(),
                  style: Theme.of(context).textTheme.headline6!,
                ),
                subtitle: Text(
                    "Last updated: ${dateTimeToString(widget.pool.updatedAt)}"),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<PoolDescriptionCubit,
                  AsyncLoadState<PoolDescriptionState>>(
                builder: (context, state) {
                  if (state.status == LoadStatus.success) {
                    return Html(
                      onLinkTap: (url, context, attributes, element) =>
                          _onHtmlLinkTapped(attributes, url,
                              state.data!.descriptionEndpointRefUrl),
                      data: state.data!.description,
                    );
                  } else if (state.status == LoadStatus.failure) {
                    return const SizedBox.shrink();
                  } else {
                    return const Center(
                      child: LinearProgressIndicator(),
                    );
                  }
                },
              ),
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
                                value: BlocProvider.of<NoteBloc>(context)
                                  ..add(NoteRequested(postId: post.id))),
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

void _onHtmlLinkTapped(
  Map<String, String> attributes,
  String? url,
  String endpoint,
) {
  if (url == null) return;

  if (!attributes.containsKey('class')) return;
  final att = attributes['class']!.split(' ').toList();
  if (att.isEmpty) return;
  if (att.contains('dtext-external-link')) {
    launchExternalUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppWebView,
    );
  } else if (att.contains('dtext-wiki-link')) {
    launchExternalUrl(
      Uri.parse("$endpoint$url"),
      mode: LaunchMode.inAppWebView,
    );
  } else if (att.contains('dtext-post-search-link')) {
// AppRouter.router.navigateTo(
//             context,
//             "/posts/search",
//             routeSettings: RouteSettings(arguments: [tag.rawName]),
//           )
  }
}

String dateTimeToString(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  final ago = now.subtract(diff);

  return timeago.format(ago);
}
