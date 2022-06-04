// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/services/download_service.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/comment/comment_page.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/modals/slide_show_config_bottom_modal.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_image_page.dart';
import 'package:boorusama/core/presentation/widgets/animated_spinning_icon.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'providers/slide_show_providers.dart';

class PostDetailPage extends HookWidget {
  PostDetailPage({
    Key? key,
    required this.post,
    required this.posts,
    required this.intitialIndex,
    required this.onExit,
    required this.onPostChanged,
  }) : super(key: key);

  final int intitialIndex;
  final ValueChanged<int> onExit;
  final ValueChanged<int> onPostChanged;
  final Post post;
  final List<Post> posts;

  Widget build(BuildContext context) {
    final tickerProvider = useSingleTickerProvider();
    final spinningIconpanelAnimationController = useAnimationController(
        vsync: tickerProvider, duration: Duration(seconds: 200));
    final rotateAnimation = Tween<double>(begin: 0.0, end: 360.0)
        .animate(spinningIconpanelAnimationController);
    final showSlideShowConfig = useState(false);
    final autoPlay = useState(false);
    final slideShowConfig =
        useProvider(slideShowConfigurationStateProvider).state;
    useValueChanged(showSlideShowConfig.value, (bool _, Null __) {
      if (showSlideShowConfig.value) {
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          final confirm = await showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) =>
                    Wrap(children: [SlideShowConfigBottomModal()]),
              ) ??
              false;
          showSlideShowConfig.value = false;
          autoPlay.value = confirm;
        });
      }
    });

    final currentPostIndex = useState(posts.indexOf(post));

    useValueChanged(autoPlay.value, (_, Null __) {
      if (autoPlay.value) {
        spinningIconpanelAnimationController.repeat();
      } else {
        spinningIconpanelAnimationController.stop();
        spinningIconpanelAnimationController.reset();
      }
    });

    final hideFabAnimController = useAnimationController(
        duration: kThemeAnimationDuration, initialValue: 1);

    Widget _buildSlideShowButton() {
      return Align(
        alignment: Alignment(0.9, -0.96),
        child: ButtonBar(
          children: [
            autoPlay.value
                ? AnimatedSpinningIcon(
                    icon: Icon(Icons.sync),
                    animation: rotateAnimation,
                    onPressed: () => autoPlay.value = false,
                  )
                : IconButton(
                    icon: Icon(Icons.slideshow),
                    onPressed: () => showSlideShowConfig.value = true,
                  ),
            PopupMenuButton<PostAction>(
              onSelected: (value) async {
                switch (value) {
                  case PostAction.download:
                    context
                        .read(downloadServiceProvider)
                        .download(posts[currentPostIndex.value]);
                    break;
                  default:
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PostAction>>[
                PopupMenuItem<PostAction>(
                  value: PostAction.download,
                  child: ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text("Download"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildBackButton() {
      return Align(
        alignment: Alignment(-0.9, -0.96),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              onExit(currentPostIndex.value);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        onExit(currentPostIndex.value);
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        // floatingActionButton: autoPlay.value
        //     ? SizedBox.shrink()
        //     : FadeTransition(
        //         opacity: hideFabAnimController,
        //         child: ScaleTransition(
        //           scale: hideFabAnimController,
        //           child: FloatingActionButton(
        //             onPressed: () => showBarModalBottomSheet(
        //               expand: false,
        //               context: context,
        //               builder: (context) => CommentPage(
        //                 // comments: comments,
        //                 postId: posts[currentPostIndex.value].id,
        //               ),
        //             ),
        //             child: FaIcon(
        //               FontAwesomeIcons.comment,
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //       ),
        body: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: posts.length,
              itemBuilder: (context, index, realIndex) {
                WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                  currentPostIndex.value = index;
                });
                return PostDetail(
                  post: posts[index],
                  minimal: autoPlay.value,
                  animController: hideFabAnimController,
                );
              },
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  onPostChanged(index);
                },
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                initialPage: intitialIndex,
                reverse: false,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlay: autoPlay.value,
                autoPlayAnimationDuration: slideShowConfig.skipAnimation
                    ? Duration(microseconds: 1)
                    : Duration(milliseconds: 600),
                autoPlayInterval: Duration(seconds: slideShowConfig.interval),
                scrollDirection: Axis.horizontal,
              ),
            ),
            ShadowGradientOverlay(
              alignment: Alignment.topCenter,
              colors: <Color>[
                const Color(0x5D000000),
                Colors.black12.withOpacity(0.0)
              ],
            ),
            _buildBackButton(),
            _buildSlideShowButton(),
          ],
        ),
      ),
    );
  }
}
