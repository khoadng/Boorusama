// Project imports:
import '../../../post/types.dart';

enum DuplicateCheckMode {
  id,
  idAndMd5,
}

class PostDuplicateTracker<T extends Post> {
  PostDuplicateTracker({
    this.mode = DuplicateCheckMode.id,
  });

  final DuplicateCheckMode mode;
  final Set<int> _idKeys = {};
  final Set<String> _md5Keys = {};

  bool isDuplicate(T item) {
    switch (mode) {
      case DuplicateCheckMode.id:
        return _idKeys.contains(item.id);
      case DuplicateCheckMode.idAndMd5:
        return _idKeys.contains(item.id) ||
            (item.md5.isNotEmpty && _md5Keys.contains(item.md5));
    }
  }

  void trackItem(T item) {
    _idKeys.add(item.id);

    if (mode == DuplicateCheckMode.idAndMd5) {
      if (item.md5.isNotEmpty) {
        _md5Keys.add(item.md5);
      }
    }
  }

  void clear() {
    _idKeys.clear();
    _md5Keys.clear();
  }

  void rebuildFrom(Iterable<T> items) {
    clear();
    items.forEach(trackItem);
  }
}
