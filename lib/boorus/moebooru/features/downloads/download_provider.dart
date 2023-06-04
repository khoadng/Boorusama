// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/downloads/downloads.dart';

final moebooruDownloadFileNameGeneratorProvider = Provider<FileNameGenerator>(
    (ref) => DownloadUrlBaseNameFileNameGenerator());
