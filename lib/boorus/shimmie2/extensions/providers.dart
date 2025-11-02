// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../client_provider.dart';
import 'state.dart';
import 'types.dart';

final shimmie2ExtensionsProvider = AsyncNotifierProvider.autoDispose
    .family<Shimmie2ExtensionsNotifier, Shimmie2ExtensionsState, String>(
      Shimmie2ExtensionsNotifier.new,
    );

class Shimmie2ExtensionsNotifier
    extends AutoDisposeFamilyAsyncNotifier<Shimmie2ExtensionsState, String> {
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
