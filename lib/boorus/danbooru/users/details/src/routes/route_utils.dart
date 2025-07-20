// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/router.dart';
import '../types/user_details.dart';

void goToUserDetailsPage(
  WidgetRef ref, {
  required UserDetails details,
}) {
  final uid = details.id;
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'users',
        '$uid',
      ],
      queryParameters: {
        ...details.toQueryParams(),
      },
    ).toString(),
  );
}

void goToProfilePage(WidgetRef ref) {
  ref.router.push(
    Uri(
      pathSegments: [
        '',
        'danbooru',
        'profile',
      ],
    ).toString(),
  );
}
