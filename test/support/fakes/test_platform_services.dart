// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coreutils/coreutils.dart';

// Project imports:
import 'package:boorusama/foundation/applock/src/device_authenticator.dart';
import 'package:boorusama/foundation/networking/connectivity_service.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';
import 'package:boorusama/foundation/window.dart';
import 'package:boorusama/core/http/cookies/providers.dart';
import 'package:boorusama/foundation/webview_user_agent.dart';
import 'package:boorusama/foundation/url_launcher.dart';

final class TestConnectivityService implements ConnectivityService {
  const TestConnectivityService({this.result = ConnectivityResult.wifi});

  final ConnectivityResult result;

  @override
  Stream<List<ConnectivityResult>> get changes => const Stream.empty();

  @override
  Future<List<ConnectivityResult>> getCurrent() async => [result];
}

final class TestDeviceAuthenticator implements DeviceAuthenticator {
  const TestDeviceAuthenticator();

  @override
  Future<bool> get canCheckBiometrics async => false;

  @override
  Future<bool> isDeviceSupported() async => false;

  @override
  Future<bool> authenticate({required String localizedReason}) async => false;
}

final class TestWebViewUserAgentService implements WebViewUserAgentService {
  const TestWebViewUserAgentService({this.userAgent = 'HeadlessWebView/1.0'});

  final String? userAgent;

  @override
  Future<String?> getUserAgent() async => userAgent;
}

final class MemoryCookieJarFactory implements CookieJarFactory {
  const MemoryCookieJarFactory();

  @override
  Future<CookieJar> create() async => CookieJar();
}

final class TestAppFilePicker implements AppFilePicker {
  TestAppFilePicker({this.filePath, this.directoryPath});

  String? filePath;
  String? directoryPath;
  final pickedFiles = <String>[];
  final pickedDirectories = <String>[];

  @override
  Future<String?> pickFile({
    List<String>? allowedExtensions,
    bool customFileType = false,
  }) async {
    if (filePath case final path?) pickedFiles.add(path);
    return filePath;
  }

  @override
  Future<String?> pickDirectory({String? initialDirectory}) async {
    if (directoryPath case final path?) pickedDirectories.add(path);
    return directoryPath;
  }
}

final class RecordingExternalUrlLauncher implements ExternalUrlLauncher {
  final launched = <(Uri, ExternalLaunchMode)>[];

  @override
  Future<bool> launch(
    Uri url, {
    ExternalLaunchMode mode = ExternalLaunchMode.externalApplication,
  }) async {
    launched.add((url, mode));
    return true;
  }
}

final class MemoryPinCredentialRepositoryFactory
    implements PinCredentialRepositoryFactory {
  MemoryPinCredentialRepositoryFactory([
    MemoryPinCredentialStore? store,
  ]) : store = store ?? MemoryPinCredentialStore();

  final MemoryPinCredentialStore store;

  @override
  PinCredentialRepository create() => PinCredentialRepository.fromStore(
    store,
  );

  @override
  Future<void> dispose(PinCredentialRepository repository) =>
      repository.close();
}

final class MemoryPinCredentialStore implements PinCredentialStore {
  final _values = <String, String>{};

  @override
  Future<String?> get(String key) async => _values[key];

  @override
  Future<void> put(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> close() async {}
}

final class TestWindowService implements WindowService {
  const TestWindowService();

  @override
  Future<bool> isAlwaysOnTop() async => false;

  @override
  Future<void> setAlwaysOnTop(bool value) async {}
}
