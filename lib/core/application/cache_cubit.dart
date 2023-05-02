// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/utils/file_utils.dart';

class CacheCubit extends Cubit<int> {
  CacheCubit() : super(0) {
    calculateCacheSize();
  }

  Future<void> clearAppCache() async {
    await clearCache();
    emit(0);
  }

  Future<void> calculateCacheSize() async {
    final cacheSize = await getCacheSize();
    emit(cacheSize);
  }
}
