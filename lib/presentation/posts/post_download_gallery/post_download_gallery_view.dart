import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:widget_view/widget_view.dart';

class PostDownloadGalleryView extends StatefulWidgetView<
    PostDownloadGalleryPage, PostDownloadGalleryState> {
  PostDownloadGalleryView(PostDownloadGalleryState controller, {Key key})
      : super(controller, key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          return controller.files.isNotEmpty
              ? Image.file(controller.files[index])
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
