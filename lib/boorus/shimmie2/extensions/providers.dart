// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/http/types.dart';
import '../../../foundation/info/app_info.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/vendors/google/providers.dart';
import 'state.dart';
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
    final packageInfo = ref.watch(packageInfoProvider);
    final appInfo = ref.watch(appInfoProvider);
    final loggerService = ref.watch(loggerProvider);
    final cronetAvailable = ref.watch(isGooglePlayServiceAvailableProvider);

    return newGenericDio(
      baseUrl: baseUrl,
      userAgent: getDefaultUserAgent(appInfo, packageInfo),
      logger: loggerService,
      protocolInfo: NetworkProtocolInfo.generic(
        cronetAvailable: cronetAvailable,
      ),
    );
  },
);

final shimmie2ExtensionsProvider =
    AsyncNotifierProvider.family<
      Shimmie2ExtensionsNotifier,
      Shimmie2ExtensionsState,
      String
    >(Shimmie2ExtensionsNotifier.new);

class Shimmie2ExtensionsNotifier
    extends FamilyAsyncNotifier<Shimmie2ExtensionsState, String> {
  @override
  Future<Shimmie2ExtensionsState> build(String arg) async {
    final shimmie2Client = ref.watch(shimmie2AnonymousClientProvider(arg));
    final result = await shimmie2Client.getExtensions();

    return switch (result) {
      ExtensionsSuccess(:final extensions) => Shimmie2ExtensionsData(
        extensions: extensions.map(Extension.fromDto).toList(),
      ),
      ExtensionsNotSupported() => const Shimmie2ExtensionsNotSupported(),
    };
  }
}
