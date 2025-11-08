// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../clients/providers.dart';

class BulkOperationState {
  const BulkOperationState({
    this.isFavoriting = false,
    this.isUnfavoriting = false,
  });

  final bool isFavoriting;
  final bool isUnfavoriting;

  bool get isOperating => isFavoriting || isUnfavoriting;

  BulkOperationState copyWith({
    bool? isFavoriting,
    bool? isUnfavoriting,
  }) => BulkOperationState(
    isFavoriting: isFavoriting ?? this.isFavoriting,
    isUnfavoriting: isUnfavoriting ?? this.isUnfavoriting,
  );
}

class BulkOperationNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<BulkOperationState, BooruConfigAuth> {
  @override
  Future<BulkOperationState> build(BooruConfigAuth arg) async =>
      const BulkOperationState();

  Future<bool> favorite(List<int> postIds) async {
    state = const AsyncData(BulkOperationState(isFavoriting: true));

    try {
      final client = ref.read(shimmie2ClientProvider(arg));
      final success = await client.bulkAction(
        action: BulkAction.favorite,
        postIds: postIds,
      );

      state = const AsyncData(BulkOperationState());
      return success;
    } catch (_) {
      state = const AsyncData(BulkOperationState());
      return false;
    }
  }

  Future<bool> unfavorite(List<int> postIds) async {
    state = const AsyncData(BulkOperationState(isUnfavoriting: true));

    try {
      final client = ref.read(shimmie2ClientProvider(arg));
      final success = await client.bulkAction(
        action: BulkAction.unfavorite,
        postIds: postIds,
      );

      state = const AsyncData(BulkOperationState());

      return success;
    } catch (_) {
      state = const AsyncData(BulkOperationState());
      return false;
    }
  }
}

final bulkOperationProvider = AsyncNotifierProvider.autoDispose
    .family<BulkOperationNotifier, BulkOperationState, BooruConfigAuth>(
      BulkOperationNotifier.new,
    );
