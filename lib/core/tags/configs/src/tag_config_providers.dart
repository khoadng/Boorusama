// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/loggers.dart';
import 'tag_info.dart';
import 'tag_info_service.dart';

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());

Future<Override> createTagInfoOverride({
  required BootLogger bootLogger,
}) async {
  bootLogger.l('Initialize tag info');
  final tagInfo =
      await TagInfoService.create().then((value) => value.getInfo());

  return tagInfoProvider.overrideWithValue(tagInfo);
}
