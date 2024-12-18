// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'cache_notifier.dart';

final miscDataBoxProvider = Provider<Box<String>>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'miscDataBoxProvider',
);

final miscDataProvider = NotifierProvider.autoDispose
    .family<MiscDataNotifier, String, String>(MiscDataNotifier.new);

final cacheSizeProvider =
    NotifierProvider.autoDispose<CacheSizeNotifier, CacheSizeInfo>(
  CacheSizeNotifier.new,
);

class MiscDataNotifier extends AutoDisposeFamilyNotifier<String, String> {
  @override
  String build(String arg) {
    final miscDataBox = ref.watch(miscDataBoxProvider);
    return miscDataBox.get(arg) ?? '';
  }

  Future<void> put(String value) async {
    final miscDataBox = ref.watch(miscDataBoxProvider);
    await miscDataBox.put(arg, value);

    state = value;
  }
}
