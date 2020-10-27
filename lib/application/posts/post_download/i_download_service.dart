import 'package:boorusama/domain/posts/post.dart';
import 'package:flutter/cupertino.dart';

abstract class IDownloadService {
  void download(Post post, String url);
  Future<Null> init(TargetPlatform platform);
  void dispose();
}
