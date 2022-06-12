// Dart imports:
import 'dart:collection';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

extension QueueX<E> on Queue<E> {
  List<E> dequeue(int times) {
    final list = <E>[];
    for (var i = 0; i < times - 1; i++) {
      if (isEmpty) break;
      list.add(removeFirst());
    }
    return list;
  }
}
