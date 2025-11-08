// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:coreutils/coreutils.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../core/http/client/providers.dart';
import '../../../core/http/client/types.dart';
import '../../../foundation/loggers.dart';
import 'cache.dart';
import 'parser.dart';
import 'types.dart';

final shimmie2AnonymousClientProvider = Provider.family<Shimmie2Client, String>(
  (ref, baseUrl) {
    final dio = ref.watch(shimmie2AnonymousDioProvider(baseUrl));

    return Shimmie2Client(
      dio: dio,
      baseUrl: baseUrl,
    );
  },
);

final shimmie2AnonymousDioProvider = Provider.family<Dio, String>(
  (ref, baseUrl) {
    final loggerService = ref.watch(loggerProvider);

    return newGenericDio(
      baseUrl: baseUrl,
      userAgent: ref.watch(defaultUserAgentProvider),
      logger: loggerService,
      protocolInfo: NetworkProtocolInfo.generic(),
    );
  },
);

final shimmie2VersionProvider = FutureProvider.family<Version?, String>(
  (ref, baseUrl) async {
    final shimmie2Client = ref.watch(shimmie2AnonymousClientProvider(baseUrl));
    final extensionsResult = await shimmie2Client.getExtensions();

    return switch (extensionsResult) {
      ExtensionsSuccess(:final version) => version,
      ExtensionsNotSupported() => null,
    };
  },
);

final _extensionsCacheProvider = Provider<ExtensionsCache>(
  (ref) => LazyExtensionsCache(() async {
    return ExtensionsCacheHive(await Hive.openBox('shimmie2_extensions_cache'));
  }),
);

final shimmie2ExtensionsProvider =
    AsyncNotifierProvider.family<
      Shimmie2ExtensionsNotifier,
      Shimmie2ExtensionsState,
      String
    >(Shimmie2ExtensionsNotifier.new);

class Shimmie2ExtensionsNotifier
    extends FamilyAsyncNotifier<Shimmie2ExtensionsState, String> {
  static const _cacheTtl = Duration(days: 7);

  @override
  Future<Shimmie2ExtensionsState> build(String arg) async {
    final cache = ref.watch(_extensionsCacheProvider);
    final cacheKey = _cacheKey(arg);

    try {
      final cachedExtensions = await cache.get(cacheKey);
      if (cachedExtensions != null) {
        final timestamp = await cache.getTimestamp(cacheKey);
        final isExpired = _isCacheExpired(timestamp);

        if (!isExpired) {
          return Shimmie2ExtensionsData(
            extensions: cachedExtensions,
            lastUpdateTimestamp: timestamp,
          );
        }
      }
    } catch (_) {
      // Cache is corrupted, remove it and fetch fresh data
      await cache.remove(cacheKey);
    }

    final shimmie2Client = ref.watch(shimmie2AnonymousClientProvider(arg));
    final result = await shimmie2Client.getExtensions();

    return switch (result) {
      ExtensionsSuccess(:final extensions, :final version) => () {
        final extensionsList = extensions.map(extensionDtoToExtension).toList();
        final now = DateTime.now();
        cache.set(cacheKey, extensionsList);
        cache.setTimestamp(cacheKey, now);
        return Shimmie2ExtensionsData(
          extensions: extensionsList,
          version: version,
          lastUpdateTimestamp: now,
        );
      }(),
      ExtensionsNotSupported() => const Shimmie2ExtensionsNotSupported(),
    };
  }

  bool _isCacheExpired(DateTime? timestamp) {
    if (timestamp == null) return true;
    final age = DateTime.now().difference(timestamp);
    return age > _cacheTtl;
  }

  Future<void> refresh() async {
    final baseUrl = arg;
    final cache = ref.read(_extensionsCacheProvider);
    final cacheKey = _cacheKey(baseUrl);

    await cache.remove(cacheKey);
    ref.invalidateSelf();
  }

  String _cacheKey(String baseUrl) {
    final hash = sha256.convert(utf8.encode(baseUrl)).toString();
    return 'extensions_$hash';
  }
}

sealed class Shimmie2ExtensionsState extends Equatable {
  const Shimmie2ExtensionsState();
}

class Shimmie2ExtensionsNotSupported extends Shimmie2ExtensionsState {
  const Shimmie2ExtensionsNotSupported();

  @override
  List<Object?> get props => [];
}

class Shimmie2ExtensionsData extends Shimmie2ExtensionsState {
  const Shimmie2ExtensionsData({
    required this.extensions,
    this.version,
    this.lastUpdateTimestamp,
  });

  factory Shimmie2ExtensionsData.empty() =>
      const Shimmie2ExtensionsData(extensions: []);

  final List<Extension> extensions;
  final Version? version;
  final DateTime? lastUpdateTimestamp;

  bool hasExtension(KnownExtension extension) =>
      extensions.any((e) => e.matches(extension));

  Map<String, List<Extension>> getAllByCategory() {
    final grouped = <String, List<Extension>>{};
    for (final ext in extensions) {
      grouped.putIfAbsent(ext.category, () => []).add(ext);
    }
    return grouped;
  }

  List<String> getCategoriesSorted() {
    final categories = getAllByCategory().keys.toList();
    categories.sort();
    return categories;
  }

  @override
  List<Object?> get props => [
    extensions,
    version,
    lastUpdateTimestamp,
  ];
}
