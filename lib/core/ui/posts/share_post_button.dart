// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/modal_share.dart';

class SharePostButton extends StatelessWidget {
  const SharePostButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostShareCubit, PostShareState>(
      builder: (context, state) {
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
                    onTapFile: (filePath) =>
                        Share.shareXFiles([XFile(filePath)]),
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
                      onTapFile: (filePath) =>
                          Share.shareXFiles([XFile(filePath)]),
                      imagePath: state.booruImagePath,
                    ),
                  ),
                ),
          icon: const FaIcon(
            FontAwesomeIcons.share,
          ),
        );
      },
    );
  }
}
