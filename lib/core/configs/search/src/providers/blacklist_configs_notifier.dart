// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../config/types.dart';
import '../../../create/create.dart';
import '../../../create/providers.dart';
import '../types/blacklist_combination_mode.dart';
import '../types/blacklist_configs.dart';
import '../types/utils.dart';

final blacklistConfigsProvider = NotifierProvider.autoDispose
    .family<BlacklistConfigsNotifier, BlacklistConfigs, EditBooruConfigId>(
      BlacklistConfigsNotifier.new,
    );

class BlacklistConfigsNotifier
    extends AutoDisposeFamilyNotifier<BlacklistConfigs, EditBooruConfigId> {
  @override
  BlacklistConfigs build(EditBooruConfigId arg) {
    final editNotifier = ref.watch(editBooruConfigProvider(arg).notifier);

    listenSelf(
      (prev, next) {
        if (prev != null && next != prev) {
          editNotifier.updateBlacklistConfigs(next);
        }
      },
    );

    return ref.watch(
          editBooruConfigProvider(
            arg,
          ).select((value) => value.blacklistConfigsTyped),
        ) ??
        BlacklistConfigs.defaults();
  }

  void changeEnable(bool value) {
    state = state.copyWith(enable: value);
  }

  void changeMode(BlacklistCombinationMode mode) {
    state = state.copyWith(combinationMode: mode.id);
  }

  void addTag(String tag) {
    final currentTags = queryAsList(state.blacklistedTags);
    final newTags = currentTags.isEmpty ? [tag] : [...currentTags, tag];
    final tagString = jsonEncode(newTags);

    state = state.copyWith(
      blacklistedTags: tagString,
    );
  }

  void removeTag(String tag) {
    final currentTags = queryAsList(state.blacklistedTags);
    final newTags = currentTags.where((e) => e != tag).toList();
    final tagString = jsonEncode(newTags);

    state = state.copyWith(
      blacklistedTags: tagString,
    );
  }

  void clearTags() {
    state = state.copyWith(
      blacklistedTags: null,
    );
  }

  void editTag(String oldTag, String newTag) {
    final currentTags = queryAsList(state.blacklistedTags);
    final newTags = currentTags.map((e) => e == oldTag ? newTag : e).toList();
    final tagString = jsonEncode(newTags);

    state = state.copyWith(
      blacklistedTags: tagString,
    );
  }
}
