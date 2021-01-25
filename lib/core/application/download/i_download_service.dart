// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/core/domain/i_downloadable.dart';

abstract class IDownloadService {
  void download(IDownloadable downloadable);
  Future<Null> init(TargetPlatform platform);
  void dispose();
}
