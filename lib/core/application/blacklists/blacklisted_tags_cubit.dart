// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/blacklists/blacklisted_tag.dart';
import 'package:boorusama/core/domain/blacklists/blacklisted_tag_repository.dart';
import 'blacklisted_tags_state.dart';

class BlacklistedTagCubit extends Cubit<BlacklistState> {
  final BlacklistedTagRepository _blacklistRepository;

  BlacklistedTagCubit(this._blacklistRepository) : super(BlacklistLoading());

  Future<void> getBlacklist() async {
    try {
      final tags = await _blacklistRepository.getBlacklist();
      emit(BlacklistLoaded(tags));
    } catch (e) {
      emit(BlacklistError());
    }
  }

  Future<void> addTag(String tag) async {
    try {
      await _blacklistRepository.addTag(tag);
      getBlacklist();
    } catch (e) {
      emit(BlacklistError());
    }
  }

  Future<void> removeTag(BlacklistedTag tag) async {
    try {
      await _blacklistRepository.removeTag(tag.id);
      getBlacklist();
    } catch (e) {
      emit(BlacklistError());
    }
  }
}
