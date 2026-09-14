// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import 'tag_info.dart';
import 'tag_info_service.dart';

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());

Future<TagInfo> loadTagInfo({
  required Logger logger,
}) {
  logger.debugBoot('Initialize tag info');
  return TagInfoService.create().then(
    (value) => value.getInfo(),
  );
}
