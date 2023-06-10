// Dart imports:
import 'dart:collection';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
        <K, List<E>>{},
        (Map<K, List<E>> map, E element) =>
            map..putIfAbsent(keyFunction(element), () => <E>[]).add(element),
      );
}

extension QueueX<E> on Queue<E> {
  List<E> dequeue(int times) {
    final list = <E>[];
    for (var i = 0; i < times; i++) {
      if (isEmpty) break;
      list.add(removeFirst());
    }

    return list;
  }
}

extension ListX<E> on List<E> {
  List<E> replaceAt(
    int index,
    E e,
  ) {
    final items = [...this];

    if (index < 0 || index > length - 1) return this;

    items[index] = e;

    return items;
  }

  List<E> replaceFirst(
    E e,
    bool Function(E item) selector,
  ) {
    final items = [...this];

    final index = items.indexWhere((el) => selector(el));

    if (index < 0) return this;

    return replaceAt(index, e);
  }

  E? getOrNull(int index) {
    try {
      return this[index];
    } catch (e) {
      return null;
    }
  }

  E? firstOrNull(bool Function(E e) selector) {
    try {
      return firstWhere(selector);
    } catch (e) {
      return null;
    }
  }
}
