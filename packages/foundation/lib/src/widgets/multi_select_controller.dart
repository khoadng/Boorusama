// Flutter imports:
import 'package:flutter/foundation.dart';

class MultiSelectController extends ChangeNotifier {
  bool _multiSelectEnabled = false;
  final Set<int> _selectedItems = <int>{};

  final ValueNotifier<Set<int>> selectedItemsNotifier = ValueNotifier({});
  final ValueNotifier<bool> multiSelectNotifier = ValueNotifier(false);

  bool get multiSelectEnabled => _multiSelectEnabled;

  void enableMultiSelect({
    List<int>? initialSelected,
  }) {
    _setMultiSelect(true);

    if (initialSelected != null) {
      _selectedItems.addAll(initialSelected);
      notifySelectedItems();
    }

    notifyListeners();
  }

  void disableMultiSelect() {
    _setMultiSelect(false);
    _selectedItems.clear();
    notifySelectedItems();
    notifyListeners();
  }

  void toggleMultiSelect() {
    _setMultiSelect(!_multiSelectEnabled);
    notifyListeners();
  }

  void toggleSelection(int item) {
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

  void selectAll(List<int> items) {
    _selectedItems.addAll(items);
    notifySelectedItems();
    notifyListeners();
  }

  void notifySelectedItems() {
    selectedItemsNotifier.value = _selectedItems.toSet();
  }

  void _setMultiSelect(bool value) {
    if (_multiSelectEnabled == value) return;

    _multiSelectEnabled = value;
    multiSelectNotifier.value = value;
  }

  List<int> get selectedItems => _selectedItems.toList();

  @override
  void dispose() {
    selectedItemsNotifier.dispose();
    multiSelectNotifier.dispose();
    super.dispose();
  }
}
