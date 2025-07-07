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
    return DetailsLayoutState(
      details: arg.details,
      availableParts: arg.availableParts,
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final newDetails = state.details.toList();

    final item = newDetails.removeAt(oldIndex);
    newDetails.insert(newIndex, item);

    state = state.copyWith(
      details: newDetails,
    );
  }

  void remove(CustomDetailsPartKey key) {
    final newDetails = state.details
        .where((element) => element != key)
        .toList();

    state = state.copyWith(
      details: newDetails,
    );
  }

  void add(DetailsPart part) {
    state = state.copyWith(
      details: [
        ...state.details,
        convertDetailsPart(part),
      ],
    );
  }

  void resetToDefault() {
    state = state.copyWith(
      details: arg.defaultParts.map(convertDetailsPart).toList(),
    );
  }

  void save() {
    final parts = convertDetailsParts(state.selectedParts.toList());
    arg.onUpdate(parts);
  }
}

class DetailsLayoutState extends Equatable {
  const DetailsLayoutState({
    required this.details,
    required this.availableParts,
  });

  final List<CustomDetailsPartKey> details;
  final Set<DetailsPart> availableParts;

  DetailsLayoutState copyWith({
    List<CustomDetailsPartKey>? details,
    Set<DetailsPart>? availableParts,
  }) {
    return DetailsLayoutState(
      details: details ?? this.details,
      availableParts: availableParts ?? this.availableParts,
    );
  }

  @override
  List<Object?> get props => [details, availableParts];
}

extension DetailsLayoutStateX on DetailsLayoutState {
  List<DetailsPart> get selectableParts {
    return availableParts.difference(selectedParts).toList();
  }

  Set<DetailsPart> get selectedParts {
    return details.map((e) => parseDetailsPart(e.name)).nonNulls.toSet();
  }

  (int, int) get selectedPartsCount =>
      (selectedParts.length, availableParts.length);

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
