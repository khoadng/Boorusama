// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// Project imports:
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/bookmarks.dart';

class BookmarkDetailsPage extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final int initialIndex;

  const BookmarkDetailsPage({
    Key? key,
    required this.bookmarks,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _BookmarkDetailsPageState createState() => _BookmarkDetailsPageState();
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
                PopupMenuItem(
                  value: 'view_source',
                  child: const Text('View source'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        child: PhotoViewGallery.builder(
          pageController: pageController,
          itemCount: widget.bookmarks.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(
                  widget.bookmarks[index].originalUrl),
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes:
                  PhotoViewHeroAttributes(tag: widget.bookmarks[index].id),
            );
          },
          onPageChanged: (index) => setState(() {
            currentIndex = index;
          }),
          scrollPhysics: const BouncingScrollPhysics(),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
