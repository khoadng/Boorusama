// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/widgets/widgets.dart';

class WebmVideoController {
  WebmVideoController({
    this.onCurrentPositionChanged,
    String? userAgent,
  }) {
    _webViewController = WebViewController.fromPlatformCreationParams(
        const PlatformWebViewControllerCreationParams())
      ..setUserAgent(userAgent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black);

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  late final WebViewController _webViewController;
  var _playing = false;
  bool get isPlaying => _playing;

  // Add the callback as a constructor parameter
  final void Function(double current, double total)? onCurrentPositionChanged;

  Future<void> load(String html) async {
    await _webViewController.loadHtmlString(html);
    await Future.delayed(const Duration(seconds: 1));
  }

  Timer? _positionCheckTimer;

  void _startPositionCheckTimer() {
    _positionCheckTimer?.cancel();
    _positionCheckTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      if (_playing) {
        final currentPosition = await getCurrentTime();
        final totalDuration = await getDuration();
        onCurrentPositionChanged?.call(currentPosition, totalDuration ?? 0);
      }
    });
  }

  void _stopPositionCheckTimer() {
    _positionCheckTimer?.cancel();
  }

  double? _duration;
  // get video duration
  Future<double?> getDuration() async {
    if (_duration != null) return _duration!;

    final duration = await _webViewController.runJavaScriptReturningResult(
        'document.getElementById("video").duration;');
    _duration = duration.toDoubleOrNull();
    return _duration;
  }

  // get current video time
  Future<double> getCurrentTime() async {
    final currentTime = await _webViewController.runJavaScriptReturningResult(
        'document.getElementById("video").currentTime;');
    return currentTime.toDoubleOrNull() ?? 0;
  }

  Future<void> play() async {
    _playing = true;
    _startPositionCheckTimer();
    await _webViewController
        .runJavaScript('document.getElementById("video").play();');
  }

  Future<void> pause() async {
    _playing = false;
    _stopPositionCheckTimer();
    await _webViewController
        .runJavaScript('document.getElementById("video").pause();');
  }

  Future<void> seek(double seconds) async {
    await _webViewController.runJavaScript(
        'document.getElementById("video").currentTime = $seconds;');
  }

  Future<void> mute(bool isMuted) async {
    await _webViewController
        .runJavaScript('document.getElementById("video").muted = $isMuted;');
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _webViewController.runJavaScript(
        'document.getElementById("video").playbackRate = $speed;');
  }

  Future<void> setAutoplay(bool autoplay) async {
    await _webViewController.runJavaScript(
        'document.getElementById("video").autoplay = $autoplay;');
  }

  Future<void> setLoop(bool loop) async {
    await _webViewController
        .runJavaScript('document.getElementById("video").loop = $loop;');
  }

  // dispose timer
  void dispose() {
    _stopPositionCheckTimer();
  }
}

// url to html string
String urlToHtml(
  String url, {
  Color backgroundColor = Colors.black,
  bool? muted,
}) {
  final colorText = backgroundColor == Colors.black ? 'black' : 'white';
  final mutedText = muted == true ? 'muted' : '';
  late final String videoHtml = '''
<!DOCTYPE html>
<html>
<head>
<style>
  body {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
  }
</style>
</head>
<body>
  <video id="video" allowfullscreen width="100%" height="100%" style="background-color:$colorText;vertical-align: middle;display: inline-block;" $mutedText loop>
    <source src=$url#t=0.01 type="video/webm" />
  </video>
</body>
</html>''';

  return videoHtml;
}

class EmbeddedWebViewWebm extends StatefulWidget {
  const EmbeddedWebViewWebm({
    super.key,
    required this.url,
    this.onVisibilityChanged,
    this.onCurrentPositionChanged,
    this.backgroundColor,
    this.onWebmVideoPlayerCreated,
    this.autoPlay = false,
    this.sound = true,
    required this.playbackSpeed,
    this.userAgent,
    this.onZoomUpdated,
  });

  final String url;
  final Color? backgroundColor;
  final void Function(bool value)? onVisibilityChanged;
  final void Function(double current, double total, String url)?
      onCurrentPositionChanged;
  final void Function(WebmVideoController controller)? onWebmVideoPlayerCreated;
  final bool autoPlay;
  final bool sound;
  final double playbackSpeed;
  final String? userAgent;
  final void Function(bool value)? onZoomUpdated;

  @override
  State<EmbeddedWebViewWebm> createState() => _EmbeddedWebViewWebmState();
}

class _EmbeddedWebViewWebmState extends State<EmbeddedWebViewWebm> {
  var showPlay = true;
  late final webmVideoController = WebmVideoController(
    userAgent: widget.userAgent,
    onCurrentPositionChanged: (current, total) =>
        widget.onCurrentPositionChanged?.call(current, total, widget.url),
  );
  final transformationController = TransformationController();

  @override
  void didUpdateWidget(covariant EmbeddedWebViewWebm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sound != widget.sound) {
      webmVideoController.mute(!widget.sound);
    }

    if (oldWidget.playbackSpeed != widget.playbackSpeed) {
      webmVideoController.setPlaybackSpeed(widget.playbackSpeed);
    }
  }

  @override
  void initState() {
    super.initState();
    webmVideoController.load(urlToHtml(
      widget.url,
      backgroundColor: widget.backgroundColor ?? Colors.black,
      muted: !widget.sound,
    ));
    widget.onWebmVideoPlayerCreated?.call(webmVideoController);

    transformationController.addListener(() {
      final clampedMatrix = Matrix4.diagonal3Values(
        transformationController.value.right.x,
        transformationController.value.up.y,
        transformationController.value.forward.z,
      );

      widget.onZoomUpdated?.call(!clampedMatrix.isIdentity());
    });
  }

  @override
  void dispose() {
    webmVideoController.dispose();
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveImage(
      useOriginalSize: false,
      transformationController: transformationController,
      image: GestureDetector(
        onTap: () {
          setState(() {
            showPlay = !showPlay;
            widget.onVisibilityChanged?.call(!showPlay);
          });
        },
        child: Stack(
          children: [
            Container(
              color: widget.backgroundColor,
              height: MediaQuery.sizeOf(context).height,
              child: WebViewWidget(
                  controller: webmVideoController._webViewController),
            ),
            _buildHitArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    return CenterPlayButton(
      backgroundColor: Colors.black54,
      iconColor: Colors.white,
      isFinished: false,
      isPlaying: webmVideoController.isPlaying,
      show: showPlay,
      onPressed: () {
        if (webmVideoController.isPlaying) {
          webmVideoController.pause();
        } else {
          webmVideoController.play();
        }

        setState(() {});
      },
    );
  }
}
