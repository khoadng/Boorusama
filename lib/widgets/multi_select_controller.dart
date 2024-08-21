// Flutter imports:
import 'package:flutter/foundation.dart';

class MultiSelectController<T> extends ChangeNotifier {
  bool _multiSelectEnabled = false;
  final Set<T> _selectedItems = <T>{};

  final ValueNotifier<List<T>> selectedItemsNotifier = ValueNotifier([]);

  bool get multiSelectEnabled => _multiSelectEnabled;

  set multiSelectEnabled(bool value) {
    if (_multiSelectEnabled != value) {
      _multiSelectEnabled = value;
      notifyListeners();
    }
  }

  void enableMultiSelect() {
    _multiSelectEnabled = true;
    notifyListeners();
  }

  void disableMultiSelect() {
    _multiSelectEnabled = false;
    _selectedItems.clear();
    notifySelectedItems();
    notifyListeners();
  }

  void toggleMultiSelect() {
    _multiSelectEnabled = !_multiSelectEnabled;
    notifyListeners();
  }

  void toggleSelection(T item) {
    if (_selectedItems.contains(item)) {
      _selectedItems.remove(item);
    } else {
      _selectedItems.add(item);
    }
    notifySelectedItems();
    notifyListeners();
  }

  void clearSelected() {
    _selectedItems.clear();
    notifySelectedItems();
    notifyListeners();
  }

  void selectAll(List<T> items) {
    _selectedItems.addAll(items);
    notifySelectedItems();
    notifyListeners();
  }

  void notifySelectedItems() {
    selectedItemsNotifier.value = _selectedItems.toList();
  }

  List<T> get selectedItems => _selectedItems.toList();
}
