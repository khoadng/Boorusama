// ignore_for_file: cascade_invocations

// Dart imports:
import 'dart:collection';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/dart.dart';

void main() {
  test('dequeue test', () {
    final queue = Queue<int>();
    queue.addAll([1, 2, 3, 4, 5]);
    final result = queue.dequeue(3);
    expect(result, [1, 2, 3]);
    expect(queue, [4, 5]);
  });

  test('dequeue test with times more than queue length', () {
    final queue = Queue<int>();
    queue.addAll([1, 2, 3]);
    final result = queue.dequeue(5);
    expect(result, [1, 2, 3]);
    expect(queue, []);
  });

  test('dequeue test with empty queue', () {
    final queue = Queue<int>();
    final result = queue.dequeue(3);
    expect(result, []);
    expect(queue, []);
  });

  test('dequeue test with negative times', () {
    final queue = Queue<int>();
    queue.addAll([1, 2, 3, 4, 5]);
    final result = queue.dequeue(-1);
    expect(result, []);
    expect(queue, [1, 2, 3, 4, 5]);
  });
}
