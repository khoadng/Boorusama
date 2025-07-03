// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/download.dart';
import 'background_downloader.dart';

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => BackgroundDownloader(),
);
