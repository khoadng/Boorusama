// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'app_file_system.dart';
import 'io_file_system.dart';

export 'app_file_system.dart';

final appFileSystemProvider = Provider<AppFileSystem>((ref) {
  return const IoFileSystem();
});
