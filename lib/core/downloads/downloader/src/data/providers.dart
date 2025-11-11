// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../background/providers.dart';
import '../types/download.dart';

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => ref.watch(backgroundDownloaderProvider),
);
