import 'package:boorusama/core/domain/i_downloadable.dart';
import 'package:flutter/foundation.dart';

abstract class IDownloadService {
  void download(IDownloadable downloadable);
  Future<Null> init(TargetPlatform platform);
  void dispose();
}
