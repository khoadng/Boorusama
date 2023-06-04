// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';

final gelbooruDownloadFileNameGeneratorProvider = Provider<FileNameGenerator>(
    (ref) => DownloadUrlBaseNameFileNameGenerator());
