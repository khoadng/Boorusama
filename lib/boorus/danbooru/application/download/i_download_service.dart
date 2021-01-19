import 'package:flutter/foundation.dart';

abstract class IDownloadService {
  void download(String filePath, String url);
  Future<Null> init(TargetPlatform platform);
  void dispose();
}
