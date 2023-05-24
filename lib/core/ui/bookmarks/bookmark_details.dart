// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/bookmarks/bookmark_media_item.dart';
import 'package:boorusama/core/utils.dart';

class BookmarkDetailsPage extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final int initialIndex;

  const BookmarkDetailsPage({
    Key? key,
    required this.bookmarks,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<BookmarkDetailsPage> createState() => _BookmarkDetailsPageState();
}

class _BookmarkDetailsPageState extends State<BookmarkDetailsPage> {
  late var currentIndex = widget.initialIndex;
  late final pageController = PageController(initialPage: widget.initialIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'view_source':
                  launchExternalUrl(
                    Uri.parse(widget.bookmarks[currentIndex].sourceUrl),
                  );
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'view_source',
                  child: Text('View source'),
                ),
              ];
            },
          ),
        ],
      ),
      body: BookmarkSlider(
        bookmarks: widget.bookmarks,
        initialPage: widget.initialIndex,
        onPageChange: (index) => setState(() {
          currentIndex = index;
        }),
        fullscreen: true,
      ),
    );
  }
}

class BookmarkSlider extends ConsumerStatefulWidget {
  const BookmarkSlider({
    super.key,
    required this.bookmarks,
    required this.initialPage,
    required this.onPageChange,
    required this.fullscreen,
  });

  final List<Bookmark> bookmarks;
  final int initialPage;
  final void Function(int index) onPageChange;
  final bool fullscreen;

  @override
  ConsumerState<BookmarkSlider> createState() => _PostSliderState();
}

class _PostSliderState extends ConsumerState<BookmarkSlider> {
  var enableSwipe = true;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.bookmarks.length,
      itemBuilder: (context, index, realIndex) {
        final media = BookmarkMediaItem(
          //TODO: this is used to preload image between page
          bookmark: widget.bookmarks[index],
          previewCacheManager: ref.watch(previewImageCacheManagerProvider),
          onZoomUpdated: (zoom) {
            final swipe = !zoom;
            if (swipe != enableSwipe) {
              setState(() {
                enableSwipe = swipe;
              });
            }
          },
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: media,
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        scrollPhysics: enableSwipe
            ? const PageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        height: MediaQuery.of(context).size.height,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        initialPage: widget.initialPage,
        onPageChanged: (index, reason) => widget.onPageChange(index),
      ),
    );
  }
}

class PageViewScrollPhysics extends ScrollPhysics {
  const PageViewScrollPhysics({super.parent});

  @override
  PageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
