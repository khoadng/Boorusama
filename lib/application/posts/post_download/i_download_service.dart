import 'package:flutter/cupertino.dart';

abstract class IDownloadService {
  void download(String url);
  Future<Null> init(TargetPlatform platform);
  void dispose();
}
