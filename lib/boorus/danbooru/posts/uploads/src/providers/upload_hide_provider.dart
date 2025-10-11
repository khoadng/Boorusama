// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../data/providers.dart';

class DanbooruUploadHideNotifier
    extends FamilyAsyncNotifier<DanbooruUploadHideState, BooruConfigAuth> {
  @override
  FutureOr<DanbooruUploadHideState> build(BooruConfigAuth arg) async {
    final box = await ref.watch(
      danbooruUploadHideBoxProvider(arg).future,
    );

    final map = <int, bool>{};

    for (final key in box.keys) {
      final keyString = key.toString();
      final keyInt = int.tryParse(keyString);

      if (keyInt != null) {
        final value = box.get(keyString);
        map[keyInt] = value == 'true';
      }
    }

    return DanbooruUploadHideState(
      hiddenUploadIds: map,
      showHiddenUploads: false,
    );
  }

  Future<void> toggleShowHidden() async {
    final currentState = await future;
    state = AsyncData(currentState.toggleShowHidden());
  }

  Future<void> changeVisibility(int id, bool visible) async {
    final currentState = await future;
    final newState = currentState.setVisibility(id, visible);
    state = AsyncData(newState);

    // Persist to storage
    final box = await ref.watch(
      danbooruUploadHideBoxProvider(arg).future,
    );

    if (visible) {
      await box.delete(id.toString());
    } else {
      await box.put(id.toString(), 'true');
    }
  }
}

class DanbooruUploadHideState {
  const DanbooruUploadHideState({
    required this.hiddenUploadIds,
    required this.showHiddenUploads,
  });

  factory DanbooruUploadHideState.initial() => const DanbooruUploadHideState(
    hiddenUploadIds: {},
    showHiddenUploads: false,
  );

  final Map<int, bool> hiddenUploadIds;
  final bool showHiddenUploads;

  bool isHidden(int id) => hiddenUploadIds[id] ?? false;

  bool shouldShowInList(int id) => showHiddenUploads || !isHidden(id);

  bool shouldShowOverlay(int id) => isHidden(id);

  DanbooruUploadHideState toggleShowHidden() =>
      copyWith(showHiddenUploads: !showHiddenUploads);

  DanbooruUploadHideState hide(int id) {
    final updated = {...hiddenUploadIds};
    updated[id] = true;
    return copyWith(hiddenUploadIds: updated);
  }

  DanbooruUploadHideState unhide(int id) {
    final updated = {...hiddenUploadIds};
    updated.remove(id);
    return copyWith(hiddenUploadIds: updated);
  }

  DanbooruUploadHideState setVisibility(int id, bool visible) =>
      visible ? unhide(id) : hide(id);

  DanbooruUploadHideState copyWith({
    Map<int, bool>? hiddenUploadIds,
    bool? showHiddenUploads,
  }) => DanbooruUploadHideState(
    hiddenUploadIds: hiddenUploadIds ?? this.hiddenUploadIds,
    showHiddenUploads: showHiddenUploads ?? this.showHiddenUploads,
  );
}

final danbooruUploadHideProvider =
    AsyncNotifierProvider.family<
      DanbooruUploadHideNotifier,
      DanbooruUploadHideState,
      BooruConfigAuth
    >(DanbooruUploadHideNotifier.new);
