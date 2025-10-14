// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../user/types.dart';
import '../types/creator.dart';

Creator creatorDtoToCreator(CreatorDto? d) => d != null
    ? Creator(
        id: d.id!,
        name: d.name ?? '',
        level: UserLevel.parse(d.level),
      )
    : Creator.empty();
