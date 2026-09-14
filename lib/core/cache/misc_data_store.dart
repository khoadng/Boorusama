// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class MiscDataStore {
  String? get(String key);

  Future<void> put(String key, String value);
}

final miscDataStoreProvider = Provider<MiscDataStore>(
  (_) => throw UnimplementedError(),
  name: 'miscDataStoreProvider',
);
