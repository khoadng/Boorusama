// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

void main() {
  group('[int to UserLevel]', () {
    test('exist level mapping ', () {
      final input = [10, 20, 30, 31, 32, 35, 37, 40, 50, 60];
      final expected = [
        UserLevel.restricted,
        UserLevel.member,
        UserLevel.gold,
        UserLevel.platinum,
        UserLevel.builder,
        UserLevel.contributor,
        UserLevel.approver,
        UserLevel.moderator,
        UserLevel.admin,
        UserLevel.owner,
      ];

      expect(
        listEquals(
          input.map((e) => intToUserLevel(e)).toList(),
          expected,
        ),
        isTrue,
      );
    });

    test('out of range', () {
      final input = [-123, 999, 0];
      final expected = [
        UserLevel.member,
        UserLevel.member,
        UserLevel.member,
      ];

      expect(
        listEquals(
          input.map((e) => intToUserLevel(e)).toList(),
          expected,
        ),
        isTrue,
      );
    });
  });

  group('[string to UserLevel]', () {
    test('exist level mapping ', () {
      final input = [
        'restricted',
        'member',
        'gold',
        'platinum',
        'builder',
        'contributor',
        'approver',
        'moderator',
        'admin',
        'owner',
      ];
      final expected = [
        UserLevel.restricted,
        UserLevel.member,
        UserLevel.gold,
        UserLevel.platinum,
        UserLevel.builder,
        UserLevel.contributor,
        UserLevel.approver,
        UserLevel.moderator,
        UserLevel.admin,
        UserLevel.owner,
      ];

      expect(
        listEquals(
          input.map((e) => stringToUserLevel(e)).toList(),
          expected,
        ),
        isTrue,
      );
    });

    test('out of range', () {
      final input = ['', 'aaaaaaaaaaaaaaaaaaa', '123454'];
      final expected = [
        UserLevel.member,
        UserLevel.member,
        UserLevel.member,
      ];

      expect(
        listEquals(
          input.map((e) => stringToUserLevel(e)).toList(),
          expected,
        ),
        isTrue,
      );
    });
  });
}
