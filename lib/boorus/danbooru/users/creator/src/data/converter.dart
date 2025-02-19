// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../user/user.dart';
import '../types/creator.dart';

Creator creatorDtoToCreator(CreatorDto? d) => d != null
    ? Creator(
        id: d.id!,
        name: d.name ?? '',
        level: d.level == null ? UserLevel.member : intToUserLevel(d.level!),
      )
    : Creator.empty();
