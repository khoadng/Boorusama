// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../post/types.dart';

String buildDetailsText(DanbooruPost post) {
  final fileSizeText = post.fileSize > 0
      ? '• ${Filesize.parse(post.fileSize, round: 1)}'
      : '';
  return '${post.width.toInt()}x${post.height.toInt()} • ${post.format.toUpperCase()} $fileSizeText';
}
