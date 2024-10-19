// Dart imports:
import 'dart:collection';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
        <K, List<E>>{},
        (map, element) =>
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
    if (index < 0 || index >= length) return null;

    return this[index];
  }

  bool reorder(int oldIndex, int newIndex) {
    // Check if oldIndex and newIndex are within the bounds of the list
    if (oldIndex < 0 ||
        oldIndex >= length ||
        newIndex < 0 ||
        newIndex >= length) return false;

    final item = removeAt(oldIndex);

    insert(newIndex, item);

    return true;
  }

  Map<String, int> count({
    required String Function(E item) selector,
  }) {
    final counts = <String, int>{};

    for (final item in this) {
      final key = selector(item);

      if (counts.containsKey(key)) {
        counts[key] = counts[key]! + 1;
      } else {
        counts[key] = 1;
      }
    }

    return counts;
  }
}
