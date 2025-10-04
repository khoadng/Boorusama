// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:share_handler/share_handler.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../foundation/platform.dart';
import '../../../../../../foundation/url_launcher.dart';
import '../../../../configs/providers.dart';

class UploadToDanbooru extends ConsumerStatefulWidget {
  const UploadToDanbooru({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<UploadToDanbooru> createState() => _UploadToDanbooruState();
}

class _UploadToDanbooruState extends ConsumerState<UploadToDanbooru> {
  StreamSubscription? _sharedMediaSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Only support Android for now
    if (!isAndroid()) return;

    _sharedMediaSubscription = ShareHandler.instance.sharedMediaStream.listen(
      _onSharedTextsReceived,
    );
  }

  void _onSharedTextsReceived(SharedMedia media) {
    final text = media.content;
    final config = ref.readConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
    final booruUrl = config.url;

    if (loginDetails.hasStrictSFW) return;

    final uri = text != null ? Uri.tryParse(text) : null;
    final isHttp = uri?.scheme == 'http' || uri?.scheme == 'https';

    if (uri != null && isHttp) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          settings: const RouteSettings(name: 'upload_to_booru_confirmation'),
          builder: (context) {
            return AlertDialog(
              title: Text('Upload to Danbooru'.hc),
              content: Text(
                'Are you sure you want to upload to Danbooru?\n\n$text \n\nYou need to be logged in the browser to upload.'
                    .hc,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(context.t.generic.action.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    final encodedUri = Uri.encodeFull(uri.toString());
                    final url = '${booruUrl}uploads/new?url=$encodedUri';
                    launchExternalUrlString(url);
                  },
                  child: Text(context.t.generic.action.ok),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _sharedMediaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
