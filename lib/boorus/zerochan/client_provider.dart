// Package imports:
import 'package:booru_clients/zerochan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/config/types.dart';
import '../../core/http/providers.dart';
import '../../foundation/loggers.dart';

final zerochanClientProvider = Provider.family<ZerochanClient, BooruConfigAuth>(
  (ref, config) {
    final dio = ref.watch(dioProvider(config));
    final logger = ref.watch(loggerProvider);

    return ZerochanClient(
      dio: dio,
      logger: (message) => logger.logE('ZerochanClient', message),
    );
  },
);
