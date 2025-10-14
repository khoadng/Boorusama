// Dart imports:
import 'dart:async';

// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../client_provider.dart';

final danbooruSourceProvider =
    AsyncNotifierProvider.family<DanbooruSourceNotifier, SourceDto, String>(
      DanbooruSourceNotifier.new,
    );

class DanbooruSourceNotifier extends FamilyAsyncNotifier<SourceDto, String> {
  @override
  FutureOr<SourceDto> build(String arg) {
    return _fetch(arg);
  }

  Future<SourceDto> _fetch(String arg) {
    final config = ref.watchConfigAuth;

    final client = ref.watch(danbooruClientProvider(config));
    return client.getSource(arg);
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();

    final result = await _fetch(arg);

    state = AsyncValue.data(result);
  }
}
