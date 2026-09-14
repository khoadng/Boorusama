// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import 'package:boorusama/foundation/applock/src/device_authenticator.dart';
import 'package:boorusama/foundation/networking/connectivity_service.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';
import 'package:boorusama/foundation/window.dart';

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

final class MemoryPinCredentialRepositoryFactory
    implements PinCredentialRepositoryFactory {
  @override
  PinCredentialRepository create() => PinCredentialRepository.fromStore(
    MemoryPinCredentialStore(),
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
