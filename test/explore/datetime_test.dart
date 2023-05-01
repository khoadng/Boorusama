// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';

void main() {
  group('[explore time test]', () {
    test('add, day', () {
      expect(DateTime(1).addTimeScale(TimeScale.day), DateTime(1, 1, 2));
    });

    test('add, week', () {
      expect(DateTime(1).addTimeScale(TimeScale.week), DateTime(1, 1, 8));
    });

    test('add, month', () {
      expect(DateTime(1).addTimeScale(TimeScale.month), DateTime(1, 2));
    });

    test('subtract, day', () {
      expect(DateTime(1, 1, 2).subtractTimeScale(TimeScale.day), DateTime(1));
    });

    test('subtract, week', () {
      expect(DateTime(1, 1, 8).subtractTimeScale(TimeScale.week), DateTime(1));
    });

    test('subtract, month', () {
      expect(DateTime(1, 2).subtractTimeScale(TimeScale.month), DateTime(1));
    });
  });
}
