// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'misc_data_store.dart';

final miscDataProvider = NotifierProvider.autoDispose
    .family<MiscDataNotifier, String, String>(MiscDataNotifier.new);

class MiscDataNotifier extends AutoDisposeFamilyNotifier<String, String> {
  @override
  String build(String arg) {
    final miscDataStore = ref.watch(miscDataStoreProvider);
    return miscDataStore.get(arg) ?? '';
  }

  Future<void> put(String value) async {
    final miscDataStore = ref.watch(miscDataStoreProvider);
    await miscDataStore.put(arg, value);

    state = value;
  }
}
