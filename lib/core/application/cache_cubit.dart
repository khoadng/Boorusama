// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/utils/file_utils.dart';

class CacheCubit extends Cubit<DirectorySizeInfo> {
  CacheCubit() : super(DirectorySizeInfo.zero) {
    calculateCacheSize();
  }

  Future<void> clearAppCache() async {
    await clearCache();
    emit(DirectorySizeInfo.zero);
  }

  Future<void> calculateCacheSize() async {
    final cacheSize = await getCacheSize();
    emit(cacheSize);
  }
}
