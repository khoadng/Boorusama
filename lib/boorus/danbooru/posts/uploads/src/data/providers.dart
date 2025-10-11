// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';

final danbooruUploadHideBoxProvider =
    FutureProvider.family<Box<String>, BooruConfigAuth>((ref, config) async {
      final box = await Hive.openBox<String>(
        '${Uri.encodeComponent(config.url)}_hide_uploads_v1',
      );

      return box;
    });
