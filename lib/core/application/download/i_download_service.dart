// Project imports:
import 'package:boorusama/core/domain/i_downloadable.dart';

abstract class IDownloadService {
  void download(IDownloadable downloadable);
  Future<Null> init();
  void dispose();
}
