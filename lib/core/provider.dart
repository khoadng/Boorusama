// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/application/networking.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/bookmarks.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/loggers.dart';
import 'package:boorusama/core/infra/services/tag_info_service.dart';

final currentBooruConfigRepoProvider =
    Provider<CurrentBooruConfigRepository>((ref) => throw UnimplementedError());

final booruFactoryProvider =
    Provider<BooruFactory>((ref) => throw UnimplementedError());

final booruUserIdentityProviderProvider =
    Provider<BooruUserIdentityProvider>((ref) => throw UnimplementedError());

final tagInfoProvider = Provider<TagInfo>((ref) => throw UnimplementedError());
final metatagsProvider = Provider<List<Metatag>>(
  (ref) => ref.watch(tagInfoProvider).metatags,
  dependencies: [tagInfoProvider],
);

final booruConfigRepoProvider = Provider<BooruConfigRepository>(
  (ref) => throw UnimplementedError(),
);

final autocompleteRepoProvider =
    Provider<AutocompleteRepository>((ref) => throw UnimplementedError());

final postRepoProvider =
    Provider<PostRepository>((ref) => throw UnimplementedError());

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsRepoProvider,
  ],
);

final settingsRepoProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

final dioProvider = Provider.family<Dio, String>(
  (ref, baseUrl) {
    final dir = ref.watch(httpCacheDirProvider);
    final generator = ref.watch(userAgentGeneratorProvider);
    final loggerService = ref.watch(loggerProvider);

    return dio(dir, baseUrl, generator, loggerService);
  },
  dependencies: [
    httpCacheDirProvider,
    userAgentGeneratorProvider,
    loggerProvider,
  ],
);

final httpCacheDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError(),
);

final userAgentGeneratorProvider = Provider<UserAgentGenerator>(
  (ref) => throw UnimplementedError(),
);

final loggerProvider =
    Provider<LoggerService>((ref) => throw UnimplementedError());

final bookmarkRepoProvider = Provider<BookmarkRepository>(
  (ref) => throw UnimplementedError(),
);

final dioDownloadServiceProvider = Provider<DioDownloadService>(
  (ref) => throw UnimplementedError(),
);
