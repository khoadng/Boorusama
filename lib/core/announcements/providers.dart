// Package imports:
import 'package:booru_clients/boorusama.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/loggers.dart';
import '../../foundation/vendors/google/providers.dart';
import '../cache/persistent/providers.dart';
import '../configs/config/providers.dart';
import '../environment/providers.dart';
import '../http/client/providers.dart';
import '../http/client/types.dart';
import 'data.dart';
import 'filter.dart';
import 'types.dart';

export 'data.dart';
export 'filter.dart';
export 'types.dart';

const _kAnnouncementConnectTimeout = Duration(seconds: 3);
const _kAnnouncementReceiveTimeout = Duration(seconds: 5);
const _kAnnouncementSendTimeout = Duration(seconds: 3);

final announcementDioProvider = Provider<Dio>((ref) {
  final dio = newGenericDio(
    baseUrl: null,
    userAgent: ref.watch(defaultUserAgentProvider),
    logger: ref.watch(loggerProvider),
    protocolInfo: NetworkProtocolInfo.generic(
      cronetAvailable: ref.watch(isCronetAvailableProvider),
    ),
  );

  dio.options
    ..connectTimeout = _kAnnouncementConnectTimeout
    ..receiveTimeout = _kAnnouncementReceiveTimeout
    ..sendTimeout = _kAnnouncementSendTimeout;

  return dio;
});

final boorusamaAnnouncementClientProvider = Provider<BoorusamaClient>((ref) {
  return BoorusamaClient(
    dio: ref.watch(announcementDioProvider),
  );
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final matcher = AnnouncementMatcher(environment: environment);

  ref
      .watch(loggerProvider)
      .debug(
        'Announcement',
        'env: $environment',
      );

  return AnnouncementRepository(
    client: ref.watch(boorusamaAnnouncementClientProvider),
    logger: ref.watch(loggerProvider),
    matcher: matcher,
  );
});

final dismissedAnnouncementIdsProvider = FutureProvider<Set<String>>((
  ref,
) async {
  try {
    final box = await ref.watch(persistentCacheBoxProvider.future);

    return box.keys
        .whereType<String>()
        .where((key) => key.startsWith(kAnnouncementDismissedPrefix))
        .where((key) => box.get(key) == 'true')
        .map((key) => key.substring(kAnnouncementDismissedPrefix.length))
        .toSet();
  } catch (_) {
    return const {};
  }
});

final appAnnouncementsProvider = FutureProvider<List<AppAnnouncement>>((
  ref,
) {
  final config = ref.watchConfigAuth;
  final booruKey = config.booruType.yamlName.isNotEmpty
      ? config.booruType.yamlName
      : config.booruType.name;

  return ref
      .watch(announcementRepositoryProvider)
      .getAnnouncements(
        booruKey: booruKey,
        host: normalizeAnnouncementHost(config.url),
        dismissedIds: ref.watch(dismissedAnnouncementIdsProvider.future),
      );
});
