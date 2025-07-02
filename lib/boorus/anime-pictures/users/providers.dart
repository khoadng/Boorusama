// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../client_provider.dart';

final uidProvider = Provider.autoDispose<int>((ref) {
  throw UnimplementedError();
});

final animePicturesCurrentUserIdProvider =
    FutureProvider.family<int?, BooruConfigAuth>((ref, config) async {
  final cookie = config.passHash;
  if (cookie == null || cookie.isEmpty) return null;

  final user =
      await ref.watch(animePicturesClientProvider(config)).getProfile();

  return user.id;
});
