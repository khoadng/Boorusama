// Dart imports:
import 'dart:async';

// Package imports:
import 'package:path/path.dart' as p;
import 'package:webview_flutter_windows/webview_flutter_windows.dart' as win;

// Project imports:
import '../filesystem.dart';
import 'types.dart';

typedef WindowsRuntimeVersionProbe = Future<String?> Function();
typedef WindowsEnvironmentInitializer = Future<void> Function(String path);
typedef WindowsControllerFactory = win.WebviewController Function();
typedef WindowsProfileDirectoryResolver = Future<String> Function();

final class WindowsBrowserRuntime {
  WindowsBrowserRuntime({
    AppFileSystem? fileSystem,
    WindowsRuntimeVersionProbe? runtimeVersionProbe,
    WindowsEnvironmentInitializer? environmentInitializer,
    WindowsControllerFactory? controllerFactory,
    WindowsProfileDirectoryResolver? profileDirectoryResolver,
  }) : _fileSystem = fileSystem,
       _runtimeVersionProbe =
           runtimeVersionProbe ?? win.WebviewController.getWebViewVersion,
       _environmentInitializer =
           environmentInitializer ??
           ((path) => win.WebviewController.initializeEnvironment(
             userDataPath: path,
           )),
       _controllerFactory = controllerFactory ?? win.WebviewController.new,
       _profileDirectoryResolver = profileDirectoryResolver;

  final AppFileSystem? _fileSystem;
  final WindowsRuntimeVersionProbe _runtimeVersionProbe;
  final WindowsEnvironmentInitializer _environmentInitializer;
  final WindowsControllerFactory _controllerFactory;
  final WindowsProfileDirectoryResolver? _profileDirectoryResolver;
  var _queue = Future<void>.value();
  final _liveControllers = <win.WebviewController>{};
  final _releasedControllers = <win.WebviewController>{};

  Future<BrowserAvailability> checkAvailability({
    bool forceRefresh = false,
  }) async {
    try {
      final version = (await _runtimeVersionProbe())?.trim();
      if (version == null || version.isEmpty) {
        return const BrowserAvailability(
          kind: BrowserAvailabilityKind.runtimeMissing,
          backend: BrowserBackend.windowsWebView2,
        );
      }
      return BrowserAvailability(
        kind: BrowserAvailabilityKind.available,
        backend: BrowserBackend.windowsWebView2,
        runtimeVersion: version,
      );
    } catch (error) {
      return BrowserAvailability(
        kind: BrowserAvailabilityKind.initializationFailed,
        backend: BrowserBackend.windowsWebView2,
        failureCode: error.runtimeType.toString(),
      );
    }
  }

  Future<win.WebviewController> acquire() => _enqueue(() async {
    final availability = await checkAvailability(forceRefresh: true);
    if (availability.kind == BrowserAvailabilityKind.runtimeMissing) {
      throw const EmbeddedBrowserException(
        reason: EmbeddedBrowserFailureReason.runtimeMissing,
      );
    }
    if (!availability.isAvailable) {
      throw EmbeddedBrowserException(
        reason: EmbeddedBrowserFailureReason.initializationFailed,
        code: availability.failureCode,
      );
    }

    final profilePath = await _profilePath();
    if (_liveControllers.isEmpty) {
      try {
        await _environmentInitializer(profilePath);
      } catch (error) {
        throw EmbeddedBrowserException(
          reason: EmbeddedBrowserFailureReason.initializationFailed,
          code: error.runtimeType.toString(),
        );
      }
    }

    final controller = _controllerFactory();
    try {
      await controller.initialize();
      _liveControllers.add(controller);
      return controller;
    } catch (error) {
      try {
        await controller.dispose();
      } catch (_) {}
      throw EmbeddedBrowserException(
        reason: EmbeddedBrowserFailureReason.initializationFailed,
        code: error.runtimeType.toString(),
      );
    }
  });

  Future<void> release(win.WebviewController controller) => _enqueue(() async {
    if (_releasedControllers.contains(controller)) return;
    _releasedControllers.add(controller);
    try {
      await controller.dispose();
    } finally {
      _liveControllers.remove(controller);
    }
  });

  Future<String> _profilePath() async {
    final resolver = _profileDirectoryResolver;
    if (resolver != null) return resolver();
    final fileSystem = _fileSystem;
    if (fileSystem == null) {
      throw const EmbeddedBrowserException(
        reason: EmbeddedBrowserFailureReason.initializationFailed,
        code: 'profile_resolver_missing',
      );
    }
    final path = p.join(await fileSystem.getAppStoragePath(), 'webview2');
    await fileSystem.createDirectory(path, recursive: true);
    return path;
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final previous = _queue;
    final result = previous.then<T>(
      (_) => operation(),
      onError: (_, _) => operation(),
    );
    _queue = result.then<void>(
      (_) {},
      onError: (_, _) {},
    );
    return result;
  }
}
