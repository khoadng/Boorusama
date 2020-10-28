import 'dart:io';

import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_view.dart';
import 'package:flutter/material.dart';

import '../../../IOHelper.dart';

class PostDownloadGalleryPage extends StatefulWidget {
  PostDownloadGalleryPage({Key key}) : super(key: key);

  @override
  PostDownloadGalleryState createState() => PostDownloadGalleryState();
}

class PostDownloadGalleryState extends State<PostDownloadGalleryPage> {
  List<FileSystemEntity> files;

  @override
  void initState() {
    super.initState();
    files = List<FileSystemEntity>();
    //TODO: should use Bloc pattern
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFiles();
    });
  }

  void loadFiles() async {
    //TODO: set downloaded folder path somewhere accessable from entire app
    //TODO: R E F A C T O R
    final platform = Theme.of(context).platform;
    final downloadFolder = await IOHelper.getLocalPath('Download', platform);
    final permissionGranted = await IOHelper.checkPermission(platform);
    if (permissionGranted) {
      final dir = Directory(downloadFolder);
      //TODO: should handle images and clip only
      final images = await dir.list().toList();
      setState(() {
        files = images;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PostDownloadGalleryView(this);
}
