// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/custom_details.dart';
import '../types/details_part.dart';

class DetailsLayoutNotifier
    extends
        AutoDisposeFamilyNotifier<
          DetailsLayoutState,
          DetailsLayoutManagerParams
        > {
  @override
  DetailsLayoutState build(DetailsLayoutManagerParams arg) {
    // Convert initial details to parts and create ordered list
    final selectedParts = arg.details
        .map((e) => parseDetailsPart(e.name))
        .nonNulls
        .toSet();

    final selectedOrder = arg.details
        .map((e) => parseDetailsPart(e.name))
        .nonNulls
        .toList();

    final unselectedParts = arg.availableParts
        .difference(selectedParts)
        .toList();
    final allPartsInOrder = [...selectedOrder, ...unselectedParts];

    return DetailsLayoutState(
      allPartsInOrder: allPartsInOrder,
      selectedParts: selectedParts,
      availableParts: arg.availableParts,
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final newOrder = List<DetailsPart>.from(state.allPartsInOrder);
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);

    state = state.copyWith(allPartsInOrder: newOrder);
  }

  void toggle(DetailsPart part) {
    final newSelectedParts = Set<DetailsPart>.from(state.selectedParts);

    if (newSelectedParts.contains(part)) {
      newSelectedParts.remove(part);
    } else {
      newSelectedParts.add(part);
    }

    state = state.copyWith(selectedParts: newSelectedParts);
  }

  void resetToDefault() {
    final defaultSelectedParts = arg.defaultParts;
    final unselectedParts = arg.availableParts
        .difference(defaultSelectedParts)
        .toList();
    final allPartsInOrder = [...defaultSelectedParts, ...unselectedParts];

    state = state.copyWith(
      selectedParts: defaultSelectedParts,
      allPartsInOrder: allPartsInOrder,
    );
  }

  void save() {
    // Convert selected parts back to the format expected by the callback
    final orderedSelectedParts = state.allPartsInOrder
        .where((part) => state.selectedParts.contains(part))
        .toList();

    final parts = orderedSelectedParts.map(convertDetailsPart).toList();
    arg.onUpdate(parts);
  }
}

class DetailsLayoutState extends Equatable {
  const DetailsLayoutState({
    required this.allPartsInOrder,
    required this.selectedParts,
    required this.availableParts,
  });

  final List<DetailsPart> allPartsInOrder;
  final Set<DetailsPart> selectedParts;
  final Set<DetailsPart> availableParts;

  DetailsLayoutState copyWith({
    List<DetailsPart>? allPartsInOrder,
    Set<DetailsPart>? selectedParts,
    Set<DetailsPart>? availableParts,
  }) {
    return DetailsLayoutState(
      allPartsInOrder: allPartsInOrder ?? this.allPartsInOrder,
      selectedParts: selectedParts ?? this.selectedParts,
      availableParts: availableParts ?? this.availableParts,
    );
  }

  @override
  List<Object?> get props => [allPartsInOrder, selectedParts, availableParts];
}

extension DetailsLayoutStateX on DetailsLayoutState {
  List<DetailsPart> get selectableParts {
    return availableParts.difference(selectedParts).toList();
  }

  bool isSelected(DetailsPart part) {
    return selectedParts.contains(part);
  }

  bool get canApply => selectedParts.isNotEmpty;
}

class DetailsLayoutManagerParams extends Equatable {
  const DetailsLayoutManagerParams({
    required this.details,
    required this.availableParts,
    required this.defaultParts,
    required this.onUpdate,
  });

  final List<CustomDetailsPartKey> details;
  final Set<DetailsPart> availableParts;
  final Set<DetailsPart> defaultParts;
  final void Function(List<CustomDetailsPartKey> parts) onUpdate;

  @override
  List<Object?> get props => [
    details,
    availableParts,
    defaultParts,
    onUpdate,
  ];
}

final detailsLayoutProvider = NotifierProvider.autoDispose
    .family<
      DetailsLayoutNotifier,
      DetailsLayoutState,
      DetailsLayoutManagerParams
    >(
      DetailsLayoutNotifier.new,
    );
