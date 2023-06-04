// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/modal_share.dart';
import 'package:boorusama/foundation/display.dart';

class SharePostButton extends ConsumerWidget {
  const SharePostButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postShareProvider(post));

    return IconButton(
      onPressed: () => Screen.of(context).size == ScreenSize.small
          ? showMaterialModalBottomSheet(
              expand: false,
              context: context,
              barrierColor: Colors.black45,
              backgroundColor: Colors.transparent,
              builder: (context) => ModalShare(
                booruLink: state.booruLink,
                sourceLink: state.sourceLink,
                onTap: Share.share,
                onTapFile: (filePath) => Share.shareXFiles([XFile(filePath)]),
                imagePath: state.booruImagePath,
              ),
            )
          : showDialog(
              context: context,
              builder: (context) => AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: ModalShare(
                  booruLink: state.booruLink,
                  sourceLink: state.sourceLink,
                  onTap: Share.share,
                  onTapFile: (filePath) => Share.shareXFiles([XFile(filePath)]),
                  imagePath: state.booruImagePath,
                ),
              ),
            ),
      icon: const FaIcon(
        FontAwesomeIcons.share,
      ),
    );
  }
}
