// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/clients/danbooru/types/source_dto.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruSourceProvider =
    AsyncNotifierProvider.family<DanbooruSourceNotifier, SourceDto, String>(
        DanbooruSourceNotifier.new);

class DanbooruSourceNotifier extends FamilyAsyncNotifier<SourceDto, String> {
  @override
  FutureOr<SourceDto> build(String arg) {
    return _fetch(arg);
  }

  Future<SourceDto> _fetch(String arg) async {
    final config = ref.watchConfig;

    final client = ref.watch(danbooruClientProvider(config));
    return await client.getSource(arg);
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();

    final result = await _fetch(arg);

    state = AsyncValue.data(result);
  }
}
