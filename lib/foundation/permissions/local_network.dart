// Package imports:
import 'package:permission_handler/permission_handler.dart';

abstract interface class LocalNetworkPermissionHandler {
  Future<PermissionStatus> check();
  Future<PermissionStatus> request();
}

extension LocalNetworkPermissionHandlerX on LocalNetworkPermissionHandler {
  Future<bool> isGranted() async => switch (await check()) {
    PermissionStatus.granted => true,
    _ => false,
  };

  Future<bool> isPermanentlyDenied() async => switch (await check()) {
    PermissionStatus.permanentlyDenied => true,
    _ => false,
  };

  Future<bool> requestIfNotGranted() async => switch (await check()) {
    PermissionStatus.granted => true,
    PermissionStatus.permanentlyDenied => false,
    _ => switch (await request()) {
      PermissionStatus.granted => true,
      _ => false,
    },
  };
}

final class DefaultLocalNetworkPermissionHandler
    implements LocalNetworkPermissionHandler {
  const DefaultLocalNetworkPermissionHandler();

  @override
  Future<PermissionStatus> check() async => PermissionStatus.granted;

  @override
  Future<PermissionStatus> request() async => PermissionStatus.granted;
}

final class MockLocalNetworkPermissionHandler
    implements LocalNetworkPermissionHandler {
  var _status = PermissionStatus.denied;

  @override
  Future<PermissionStatus> check() async => _status;
  @override
  Future<PermissionStatus> request() async {
    // ignore: join_return_with_assignment
    _status = PermissionStatus.granted;
    return _status;
  }
}
