// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import 'factory.dart';

final danbooruUploadHideBoxFactoryProvider =
    Provider<DanbooruUploadHideBoxFactory>(
      (_) => const HiveDanbooruUploadHideBoxFactory(),
    );

final danbooruUploadHideBoxProvider =
    FutureProvider.family<Box<String>, BooruConfigAuth>((ref, config) async {
      final factory = ref.watch(danbooruUploadHideBoxFactoryProvider);
      final box = await factory.create(config);
      ref.onDispose(() => factory.dispose(box));

      return box;
    });
