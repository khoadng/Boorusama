// Dart imports:
import 'dart:async';

abstract class SheetStateStorage {
  Future<void> persistExpandedState(bool expanded);
  bool loadExpandedState();
}

class SheetStateStorageBuilder implements SheetStateStorage {
  const SheetStateStorageBuilder({
    required this.save,
    required this.load,
  });

  final Future<void> Function(bool expanded) save;
  final bool Function() load;

  @override
  bool loadExpandedState() => load();

  @override
  Future<void> persistExpandedState(bool expanded) => save(expanded);
}
