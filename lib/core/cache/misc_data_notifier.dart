// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final miscDataBoxProvider = Provider<Box<String>>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'miscDataBoxProvider',
);

final miscDataProvider = NotifierProvider.autoDispose
    .family<MiscDataNotifier, String, String>(MiscDataNotifier.new);

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
