// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../types/creator.dart';
import '../types/creator_repository.dart';
import 'local_providers.dart';

final danbooruCreatorsProvider =
    NotifierProvider.family<
      CreatorsNotifier,
      IMap<int, Creator>,
      BooruConfigAuth
    >(CreatorsNotifier.new);

final danbooruCreatorProvider = Provider.family<Creator?, int?>((ref, id) {
  if (id == null) return null;
  final config = ref.watchConfigAuth;
  return ref.watch(danbooruCreatorsProvider(config))[id];
});

class CreatorsNotifier
    extends FamilyNotifier<IMap<int, Creator>, BooruConfigAuth> {
  Future<CreatorRepository> get _futureRepo =>
      ref.watch(danbooruCreatorRepoProvider(arg).future);

  @override
  IMap<int, Creator> build(BooruConfigAuth arg) {
    return <int, Creator>{}.lock;
  }

  Future<void> load(List<int> ids) async {
    // only load ids that are not already loaded
    final notInCached = ids.where((id) => !state.containsKey(id)).toList();

    final repo = await _futureRepo;
    final creators = await repo.getCreatorsByIdStringComma(
      notInCached.join(','),
    );

    final map = {
      for (final creator in creators) creator.id: creator,
    }.lock;

    state = state.addAll(map);
  }
}
