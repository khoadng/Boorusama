// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'http_utils.dart';

const kChecklist = [
  'cf_chl',
  'ddos',
];

const kDefaultCloudflareChallengeTriggerStatus = {
  403,
  503,
};

class CloudflareChallengeInterceptor extends Interceptor {
  CloudflareChallengeInterceptor({
    required this.context,
    required this.cookieJar,
    this.triggerOnStatus = kDefaultCloudflareChallengeTriggerStatus,
  });

  var _userAgent = '';
  final CookieJar cookieJar;
  var _block = false;
  var _disable = false;
  final BuildContext context;
  final Set<int> triggerOnStatus;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_disable) {
      return super.onRequest(options, handler);
    }

    try {
      final cookies = await cookieJar.loadForRequest(options.uri);

      if (cookies.isNotEmpty) {
        if (_userAgent.isEmpty) {
          final webviewController = WebViewController();
          final ua = await webviewController.getUserAgent();
          if (ua == null) {
            _disable = true;
            return super.onRequest(options, handler);
          }

          _userAgent = ua;
        }

        options.headers.addAll({
          AppHttpHeaders.cookieHeader: cookies.cookieString,
          AppHttpHeaders.userAgentHeader: _userAgent,
        });
      }
    } catch (e) {
      _disable = true;
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_disable) {
      return handler.next(err);
    }

    final statusCode = err.response?.statusCode;
    if (triggerOnStatus.contains(statusCode)) {
      final body = err.response?.data;

      if (body is String) {
        final bodyString = body.toLowerCase();

        // return early if we can't find any of the checklist
        if (!kChecklist.any(bodyString.contains)) {
          return handler.next(err);
        }

        if (_block) {
          // if we already open the webview, we should not open it again
          return handler.next(err);
        }
        _block = true;

        // open webview to solve cloudflare challenge
        Navigator.of(context).push(
          CupertinoPageRoute(
            settings: const RouteSettings(name: 'challenge_solver'),
            builder: (context) {
              return CloudflareChallengeSolverPage(
                url: err.requestOptions.uri.toString(),
                onCfClearance: (cookies) {
                  // set cookies
                  cookieJar.saveFromResponse(err.requestOptions.uri, cookies);
                  _block = false;

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        );
      }
    }

    return handler.next(err);
  }
}

extension CookieJarX on List<Cookie> {
  String get cookieString => map((e) => e.toString()).join('; ');
}

class CloudflareChallengeSolverPage extends StatefulWidget {
  const CloudflareChallengeSolverPage({
    required this.url,
    required this.onCfClearance,
    super.key,
  });

  final String url;
  final void Function(List<Cookie> cookies) onCfClearance;

  @override
  State<CloudflareChallengeSolverPage> createState() =>
      _CloudflareChallengeSolverPageState();
}

class _CloudflareChallengeSolverPageState
    extends State<CloudflareChallengeSolverPage> {
  final WebViewController controller = WebViewController();
  final cookieManager = WebviewCookieManager();
  late final urlWithoutQuery =
      Uri.parse(widget.url).replace(query: '').toString();

  @override
  void initState() {
    super.initState();
    controller
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Challenge Solver'),
      ),
      body: Column(
        children: [
          _buildBanner(
            'Please stay on this screen and wait until the challenge is solved and press the button below.',
          ),
          FilledButton(
            onPressed: () async {
              final cookies = await cookieManager.getCookies(urlWithoutQuery);

              if (cookies.isNotEmpty) {
                widget.onCfClearance(cookies);
                return;
              }
            },
            child: const Text('Access Cookie'),
          ),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
