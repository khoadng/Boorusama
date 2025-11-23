// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../background/providers.dart';
import '../providers/download_notifier.dart';
import '../types/download.dart';

final downloadServiceProvider = Provider<DownloadService>(
  (ref) => ref.watch(backgroundDownloaderProvider),
);

final downloadMultipleFileCheckProvider =
    Provider.family<MultipleFileDownloadCheck, BooruConfigAuth>(
      (ref, config) =>
          () => config.booruType.canDownloadMultipleFiles,
    );
