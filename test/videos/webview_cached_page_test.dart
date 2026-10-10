// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

// Project imports:
import 'package:boorusama/core/videos/engines/src/engines/webview_booru_player.dart';
import 'package:boorusama/core/videos/engines/types.dart';
import 'package:boorusama/core/videos/lock/types.dart';
import 'package:boorusama/foundation/platform.dart';

import '../support/fakes/memory_app_file_system.dart';

void main() {
  test(
    'a cached video opened while leftover pages are cleaned up keeps its page',
    () async {
      final platform = _WebViewPlatform();
      WebViewPlatform.instance = platform;
      final fileSystem = MemoryAppFileSystem();
      await fileSystem.writeString('/memory/videos/webview/old.html', 'old');

      final deleteStarted = Completer<void>();
      final releaseDelete = Completer<void>();
      fileSystem.beforeDirectoryDelete = (_) {
        deleteStarted.complete();
        return releaseDelete.future;
      };

      WebViewBooruPlayer player() => WebViewBooruPlayer(
        wakelock: Wakelock(),
        platform: AppPlatform.android,
        fileSystem: fileSystem,
      );
      const first = CachedVideoSource(
        filePath: '/memory/videos/a.webm',
        originalUrl: 'https://example.com/a.webm',
      );
      const second = CachedVideoSource(
        filePath: '/memory/videos/b.webm',
        originalUrl: 'https://example.com/b.webm',
      );

      final firstLoad = player().initialize(first);
      await deleteStarted.future;
      final secondLoad = player().initialize(second);
      await Future<void>.delayed(Duration.zero);
      releaseDelete.complete();
      await Future.wait([firstLoad, secondLoad]);

      expect(platform.loadedFiles, hasLength(2));
      for (final page in platform.loadedFiles) {
        expect(await fileSystem.fileExists(page), isTrue, reason: page);
      }
      expect(
        await fileSystem.fileExists('/memory/videos/webview/old.html'),
        isFalse,
      );
    },
  );
}

class _WebViewPlatform extends WebViewPlatform {
  final loadedFiles = <String>[];

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => _Controller(params, loadedFiles);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _Delegate(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params, this.loadedFiles) : super.implementation();

  final List<String> loadedFiles;

  @override
  Future<void> loadFile(String absoluteFilePath) async =>
      loadedFiles.add(absoluteFilePath);

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> setUserAgent(String? userAgent) async {}

  @override
  Future<void> setVerticalScrollBarEnabled(bool enabled) async {}

  @override
  Future<void> setHorizontalScrollBarEnabled(bool enabled) async {}

  @override
  Future<void> setOverScrollMode(WebViewOverScrollMode mode) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}
}
