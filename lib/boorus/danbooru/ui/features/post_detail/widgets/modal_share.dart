// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class ModalShare extends StatelessWidget {
  const ModalShare({
    super.key,
    required this.post,
    required this.endpoint,
    required this.onTap,
    required this.onTapFile,
    required this.imagePath,
  });

  final void Function(String value) onTap;
  final void Function(String filePath) onTapFile;
  final Post post;
  final String endpoint;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (post.source != null)
              ListTile(
                title: const Text('post.detail.share.source').tr(),
                leading: const FaIcon(FontAwesomeIcons.link),
                onTap: () {
                  Navigator.of(context).pop();
                  onTap.call(getShareContent(ShareMode.source, post, endpoint));
                },
              ),
            ListTile(
              title: const Text('post.detail.share.booru').tr(),
              leading: const FaIcon(FontAwesomeIcons.box),
              onTap: () {
                Navigator.of(context).pop();
                onTap.call(getShareContent(ShareMode.booru, post, endpoint));
              },
            ),
            if (imagePath != null)
              ListTile(
                title: const Text('post.detail.share.image').tr(),
                leading: const FaIcon(FontAwesomeIcons.fileImage),
                onTap: () {
                  Navigator.of(context).pop();
                  onTapFile.call(imagePath!);
                },
              ),
          ],
        ),
      ),
    );
  }
}

enum ShareMode {
  source,
  booru,
}

String getShareContent(ShareMode mode, Post post, String endpoint) {
  final booruLink = '${endpoint}posts/${post.id}';
  if (mode == ShareMode.booru) return booruLink;
  if (post.source == null) return booruLink;

  return post.source.toString();
}
