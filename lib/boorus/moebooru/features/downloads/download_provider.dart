// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/file_name_generator.dart';

final moebooruDownloadFileNameGeneratorProvider = Provider<FileNameGenerator>(
    (ref) => DownloadUrlBaseNameFileNameGenerator());
