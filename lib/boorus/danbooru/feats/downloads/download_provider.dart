// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/feats/downloads/downloads.dart';

final danbooruDownloadFileNameGeneratorProvider =
    Provider<FileNameGenerator>((ref) => BoorusamaStyledFileNameGenerator());
